// ignore_for_file: depend_on_referenced_packages

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../domain/models/model.dart';

class TripleSorteadorController extends GetxController {
  //final RxList<String> participantes = <String>[].obs;
  final RxList<String> manzanasUnicas = <String>[].obs;
  final RxMap<String, List<ManzanaModel>> lotesPorManzana =
      <String, List<ManzanaModel>>{}.obs;
  final RxList<ParticipanteModel> participantes = <ParticipanteModel>[].obs;
  final RxList<ManzanaModel> lotesDisponibles = <ManzanaModel>[].obs;

  final RxList<String> manzanaYPosicionesDisponibles = <String>[].obs; // NUEVO

  final RxBool cargando = true.obs;

  // Nuevo: Callback para actualizar los controladores de slots
  Function? onDatosActualizados;

  // Nuevo: Indicador de actualización
  final RxBool actualizando = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await cargarDatos();
    // Configurar listener en tiempo real para Firestore
    _configurarListenerTiempoReal();
  }

  void _configurarListenerTiempoReal() {
    // Listener para participantes
    FirebaseFirestore.instance.collection('participantes').snapshots().listen((
      snapshot,
    ) {
      try {
        actualizando.value = true;

        final participantesActualizados = snapshot.docs
            .map((doc) => ParticipanteModel.fromMap(doc.data(), id: doc.id))
            .where((p) => p.haSidoSorteado == false)
            .toList();

        // Solo actualizar si hay cambios reales
        if (participantesActualizados.length != participantes.length ||
            !_listasParticipantesIguales(
              participantesActualizados,
              participantes,
            )) {
          participantes.assignAll(participantesActualizados);

          // Notificar que los datos han cambiado
          if (onDatosActualizados != null) {
            onDatosActualizados!();
          }
        }
      } catch (e) {
        print('Error en listener de participantes: $e');
      } finally {
        // Ocultar indicador después de un delay
        Future.delayed(const Duration(milliseconds: 1000), () {
          actualizando.value = false;
        });
      }
    });

    // Listener para manzanas
    FirebaseFirestore.instance.collection('manzanas').snapshots().listen((
      snapshot,
    ) {
      try {
        actualizando.value = true;

        final lotesList = snapshot.docs
            .map((doc) => ManzanaModel.fromMap(doc.id, doc.data()))
            .where((m) => m.disponible == false)
            .toList();

        // Agrupar por manzana
        final Map<String, List<ManzanaModel>> agrupado = {};
        final List<String> combinados = [];

        for (final lote in lotesList) {
          if (!agrupado.containsKey(lote.manzana)) {
            agrupado[lote.manzana] = [];
          }
          agrupado[lote.manzana]!.add(lote);
          combinados.add('${lote.manzana} - ${lote.posicion}');
        }

        // Solo actualizar si hay cambios reales
        if (combinados.length != manzanaYPosicionesDisponibles.length ||
            !_listasManzanasIguales(
              combinados,
              manzanaYPosicionesDisponibles,
            )) {
          lotesPorManzana.assignAll(agrupado);
          manzanaYPosicionesDisponibles.assignAll(combinados..sort());

          if (agrupado.isNotEmpty) {
            manzanasUnicas.assignAll(agrupado.keys.toList()..sort());
          } else {
            manzanasUnicas.clear();
          }

          // Notificar que los datos han cambiado
          if (onDatosActualizados != null) {
            onDatosActualizados!();
          }
        }
      } catch (e) {
        print('Error en listener de manzanas: $e');
      } finally {
        // Ocultar indicador después de un delay
        Future.delayed(const Duration(milliseconds: 1000), () {
          actualizando.value = false;
        });
      }
    });
  }

  // Métodos auxiliares para comparar listas
  bool _listasParticipantesIguales(
    List<ParticipanteModel> lista1,
    List<ParticipanteModel> lista2,
  ) {
    if (lista1.length != lista2.length) return false;
    for (int i = 0; i < lista1.length; i++) {
      if (lista1[i].id != lista2[i].id) return false;
    }
    return true;
  }

  bool _listasManzanasIguales(List<String> lista1, List<String> lista2) {
    if (lista1.length != lista2.length) return false;
    for (int i = 0; i < lista1.length; i++) {
      if (lista1[i] != lista2[i]) return false;
    }
    return true;
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
          .map((doc) => ParticipanteModel.fromMap(doc.data(), id: doc.id))
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

      // Verificar consistencia de los datos cargados
      if (!verificarConsistenciaDatos()) {
        print(
          'Advertencia: Se encontraron inconsistencias en los datos cargados',
        );
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
    required ParticipanteModel participanteSeleccionado,
    required String manzanaSeleccionada,
    required ManzanaModel loteSeleccionado,
  }) async {
    try {
      // Validar antes de registrar
      if (!validarGanador(
        participante: participanteSeleccionado,
        lote: loteSeleccionado,
      )) {
        print('Error de validación: No se puede registrar el ganador');
        return;
      }

      final firestore = FirebaseFirestore.instance;

      // Marcar participante como sorteado
      await firestore
          .collection('participantes')
          .doc(participanteSeleccionado.id)
          .update({'haSidoSorteado': true});

      // Marcar lote como asignado
      await firestore.collection('manzanas').doc(loteSeleccionado.id).update({
        'disponible': true,
      });

      // Crear documento en colección "ganadores"
      final ganadorData = {
        ...participanteSeleccionado.toMap(),
        'manzana': loteSeleccionado.manzana,
        'posicion': loteSeleccionado.posicion,
        'timestampGanador': DateTime.now(),
      };

      await firestore.collection('ganadores').add(ganadorData);

      print('Ganador registrado exitosamente.');

      // Los listeners de Firestore se encargarán de actualizar las listas automáticamente
    } catch (e) {
      print('Error al registrar ganador: $e');
    }
  }

  // Método para actualizar los controladores de slots
  void actualizarControladoresSlots() {
    if (onDatosActualizados != null) {
      onDatosActualizados!();
    }
  }

  // Métodos de validación para evitar selecciones duplicadas
  bool esParticipanteValido(String participanteId) {
    return participantes.any(
      (p) => p.id == participanteId && !p.haSidoSorteado,
    );
  }

  bool esManzanaValida(String manzana, String posicion) {
    return lotesPorManzana.containsKey(manzana) &&
        lotesPorManzana[manzana]!.any(
          (l) => l.posicion == posicion && !l.disponible,
        );
  }

  // Validar que el participante no haya sido sorteado
  bool validarParticipanteNoSorteado(ParticipanteModel participante) {
    if (participante.haSidoSorteado) {
      print(
        'Error: El participante ${participante.nombreCompleto} ya ha sido sorteado',
      );
      return false;
    }
    return true;
  }

  // Validar que la manzana no haya sido asignada
  bool validarManzanaDisponible(ManzanaModel lote) {
    if (lote.disponible) {
      print(
        'Error: El lote ${lote.manzana} - ${lote.posicion} ya ha sido asignado',
      );
      return false;
    }
    return true;
  }

  // Validación completa antes de registrar ganador
  bool validarGanador({
    required ParticipanteModel participante,
    required ManzanaModel lote,
  }) {
    // Verificar que el participante no haya sido sorteado
    if (!validarParticipanteNoSorteado(participante)) {
      return false;
    }

    // Verificar que la manzana no haya sido asignada
    if (!validarManzanaDisponible(lote)) {
      return false;
    }

    // Verificar que ambos elementos estén en las listas actuales
    if (!participantes.contains(participante)) {
      print(
        'Error: El participante no está en la lista actual de participantes disponibles',
      );
      return false;
    }

    final lotesDeManzana = lotesPorManzana[lote.manzana];
    if (lotesDeManzana == null || !lotesDeManzana.contains(lote)) {
      print('Error: El lote no está en la lista actual de lotes disponibles');
      return false;
    }

    return true;
  }

  // Método para verificar la consistencia de los datos
  bool verificarConsistenciaDatos() {
    // Verificar que no haya participantes duplicados
    final participantesIds = participantes.map((p) => p.id).toSet();
    if (participantesIds.length != participantes.length) {
      print('Error: Se encontraron participantes duplicados');
      return false;
    }

    // Verificar que no haya lotes duplicados
    final lotesIds = <String>{};
    for (final manzana in lotesPorManzana.values) {
      for (final lote in manzana) {
        if (lotesIds.contains(lote.id)) {
          print('Error: Se encontraron lotes duplicados');
          return false;
        }
        lotesIds.add(lote.id);
      }
    }

    // Verificar que todos los participantes en la lista no hayan sido sorteados
    for (final participante in participantes) {
      if (participante.haSidoSorteado) {
        print(
          'Error: Se encontró un participante ya sorteado en la lista de disponibles',
        );
        return false;
      }
    }

    // Verificar que todos los lotes en la lista no hayan sido asignados
    for (final manzana in lotesPorManzana.values) {
      for (final lote in manzana) {
        if (lote.disponible) {
          print(
            'Error: Se encontró un lote ya asignado en la lista de disponibles',
          );
          return false;
        }
      }
    }

    return true;
  }
}
