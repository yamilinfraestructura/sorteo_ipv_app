// ignore_for_file: depend_on_referenced_packages

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../domain/models/model.dart';

class TripleSorteadorController extends GetxController {
  final RxList<String> participantes = <String>[].obs;
  final RxList<String> manzanasUnicas = <String>[].obs;
  final RxMap<String, List<ManzanaModel>> lotesPorManzana =
      <String, List<ManzanaModel>>{}.obs;

  final RxList<String> manzanaYPosicionesDisponibles = <String>[].obs; // NUEVO

  final RxBool cargando = true.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await cargarDatos();
  }

  Future<void> cargarDatos() async {
    try {
      cargando.value = true;

      // Participantes no sorteados
      final participantesSnapshot = await FirebaseFirestore.instance
          .collection('participantes')
          .where('haSidoSorteado', isEqualTo: false)
          .get();

      final participantesList = participantesSnapshot.docs
          .map((doc) => doc['nombre'] ?? 'Sin nombre')
          .cast<String>()
          .toList();

      participantes.assignAll(participantesList);

      // Lotes disponibles (de todas las manzanas)
      final manzanasSnapshot = await FirebaseFirestore.instance
          .collection('manzanas')
          .get();

      final lotesList = manzanasSnapshot.docs
          .map((doc) => ManzanaModel.fromMap(doc.id, doc.data()))
          .where((m) => m.disponible == false)
          .toList();

      // Agrupar por manzana
      final Map<String, List<ManzanaModel>> agrupado = {};

      final List<String> combinados = [];

      for (final lote in lotesList) {
        // Agrupar para mantener compatibilidad con lógica existente
        if (!agrupado.containsKey(lote.manzana)) {
          agrupado[lote.manzana] = [];
        }
        agrupado[lote.manzana]!.add(lote);

        // Crear combinación "Manzana - Posición"
        combinados.add('${lote.manzana} - ${lote.posicion}');
      }

      lotesPorManzana.assignAll(agrupado);

      if (agrupado.isNotEmpty) {
        manzanasUnicas.assignAll(agrupado.keys.toList()..sort());
        manzanaYPosicionesDisponibles.assignAll(combinados..sort());
      } else {
        manzanasUnicas.clear();
        manzanaYPosicionesDisponibles.clear();
        print('Advertencia: No se encontraron manzanas disponibles');
      }
    } catch (e) {
      print('Error al cargar datos: $e');
      manzanasUnicas.clear();
      manzanaYPosicionesDisponibles.clear();
    } finally {
      cargando.value = false;
    }
  }

  /// Marcar lote como asignado (disponible = true)
  Future<void> marcarLoteComoAsignado(String manzana, String posicion) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('manzanas')
          .where('manzana', isEqualTo: manzana)
          .where('posicion', isEqualTo: posicion)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final docId = query.docs.first.id;
        await FirebaseFirestore.instance
            .collection('manzanas')
            .doc(docId)
            .update({'disponible': true});

        print('Lote $manzana - $posicion marcado como asignado');
      } else {
        print('No se encontró el documento para $manzana - $posicion');
      }
    } catch (e) {
      print('Error al marcar lote como asignado: $e');
    }
  }

  Future<void> registrarGanador({
    required String nombreParticipante,
    required String manzanaSeleccionada,
    required ManzanaModel loteSeleccionado,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Buscar participante completo por nombre
      final participanteSnapshot = await firestore
          .collection('participantes')
          .where('nombre', isEqualTo: nombreParticipante)
          .where('haSidoSorteado', isEqualTo: false)
          .limit(1)
          .get();

      if (participanteSnapshot.docs.isEmpty) {
        print('No se encontró al participante: $nombreParticipante');
        return;
      }

      final participanteDoc = participanteSnapshot.docs.first;
      final participanteData = participanteDoc.data();

      // Actualizar haSidoSorteado = true
      await firestore
          .collection('participantes')
          .doc(participanteDoc.id)
          .update({'haSidoSorteado': true});

      // Actualizar disponible = true en lote (manzana)
      await firestore.collection('manzanas').doc(loteSeleccionado.id).update({
        'disponible': true,
      });

      // Remover de las listas
      participantes.remove(nombreParticipante);

      // Remover lote de la manzana
      lotesPorManzana[manzanaSeleccionada]?.removeWhere(
        (lote) => lote.id == loteSeleccionado.id,
      );

      // Si ya no quedan lotes en esa manzana, quitamos la manzana también
      if (lotesPorManzana[manzanaSeleccionada]?.isEmpty ?? true) {
        lotesPorManzana.remove(manzanaSeleccionada);
        manzanasUnicas.remove(manzanaSeleccionada);
      }

      // Crear documento en colección "ganadores"
      final ganadorData = {
        ...participanteData,
        'manzana': loteSeleccionado.manzana,
        'posicion': loteSeleccionado.posicion,
        'timestampGanador': DateTime.now(),
      };

      await firestore.collection('ganadores').add(ganadorData);

      print('Ganador registrado exitosamente.');
    } catch (e) {
      print('Error al registrar ganador: $e');
    }
  }
}
