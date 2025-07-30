// ignore_for_file: depend_on_referenced_packages

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:sorteo_ipv_app/src/domain/models/participantes_model.dart';

class CargaParticipantesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var isLoading = false.obs;
  var mensaje = ''.obs;
  var participantes = <ParticipanteModel>[].obs;
  var participantesExisten = false.obs;

  // Observable para el índice seleccionado en la ruleta
  RxInt selectedIndex = 0.obs;

  // Observable para los participantes sorteados
  RxList<ParticipanteModel> participantesSorteados = <ParticipanteModel>[].obs;

  // Verificar si ya existen participantes para el sorteo actual
  Future<bool> verificarParticipantesExistentes(String idSorteoActual) async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('participantes')
          .where('idSorteo', isEqualTo: idSorteoActual)
          .limit(1)
          .get();

      participantesExisten.value = snapshot.docs.isNotEmpty;
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      mensaje.value = 'Error al verificar participantes: ${e.toString()}';
      return false;
    }
  }

  // Obtener participantes desde Firebase
  Future<void> obtenerParticipantes(String idSorteoActual) async {
    isLoading.value = true;
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('participantes')
          .where('idSorteo', isEqualTo: idSorteoActual)
          .orderBy('nro_para_sorteo')
          .get();

      List<ParticipanteModel> listaParticipantes = snapshot.docs
          .map((doc) => ParticipanteModel.fromMap(doc.data(), id: doc.id))
          .toList();

      participantes.assignAll(listaParticipantes);
      mensaje.value = 'Se cargaron ${listaParticipantes.length} participantes';
    } catch (e) {
      mensaje.value = 'Error al obtener participantes: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> importarExcel(String idSorteoActual) async {
    isLoading.value = true;
    mensaje.value = '';
    try {
      // Primero verificar si ya existen participantes
      bool yaExisten = await verificarParticipantesExistentes(idSorteoActual);
      if (yaExisten) {
        mensaje.value = 'Los participantes ya están cargados para este sorteo';
        await obtenerParticipantes(idSorteoActual);
        isLoading.value = false;
        return;
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );
      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final bytes = await File(path).readAsBytes();
        final excelFile = Excel.decodeBytes(bytes);
        final sheet = excelFile.tables.values.first;
        // ignore: unnecessary_null_comparison
        if (sheet == null) {
          mensaje.value = 'No se encontró hoja en el archivo.';
          isLoading.value = false;
          return;
        }
        List<ParticipanteModel> nuevos = [];

        for (int i = 1; i < sheet.maxRows; i++) {
          final row = sheet.row(i);
          if (row.isEmpty || row[3] == null || row[4] == null) continue;

          final participante = ParticipanteModel(
            nroParaSorteo: row[0]?.value?.toString() ?? '',
            ordenSorteado: row[1]?.value?.toString() ?? '',
            nroInscripcion: row[2]?.value?.toString() ?? '',
            dni: row[3]?.value?.toString() ?? '',
            apellido: row[4]?.value?.toString() ?? '',
            nombre: row[5]?.value?.toString() ?? '',
            sexo: row[6]?.value?.toString() ?? '',
            fNac: row[7]?.value?.toString() ?? '',
            ingresoMensual: row[8]?.value?.toString() ?? '',
            estudios: row[9]?.value?.toString() ?? '',
            fFall: row[10]?.value?.toString() ?? '',
            fBaja: row[11]?.value?.toString() ?? '',
            departamento: row[12]?.value?.toString() ?? '',
            localidad: row[13]?.value?.toString() ?? '',
            barrio: row[14]?.value?.toString() ?? '',
            domicilio: row[15]?.value?.toString() ?? '',
            tel: row[16]?.value?.toString() ?? '',
            cantOcupantes: row[17]?.value?.toString() ?? '',
            descripcion1: row[18]?.value?.toString() ?? '',
            descripcion2: row[19]?.value?.toString() ?? '',
            grupReferencial: row[20]?.value?.toString() ?? '',
            preferencialFicha: row[21]?.value?.toString() ?? '',
            ficha: row[22]?.value?.toString() ?? '',
            fAlta: row[23]?.value?.toString() ?? '',
            fmodif: row[24]?.value?.toString() ?? '',
            fBaja2: row[25]?.value?.toString() ?? '',
            expediente: row[26]?.value?.toString() ?? '',
            reemp: row[27]?.value?.toString() ?? '',
            estadoTxt: row[28]?.value?.toString() ?? '',
            circuitoipvTxt: row[29]?.value?.toString() ?? '',
            circuitoipvNota: row[30]?.value?.toString() ?? '',
            idSorteo: idSorteoActual,
          );

          await FirebaseFirestore.instance
              .collection('participantes')
              .add(participante.toMap());
          nuevos.add(participante);
        }
        participantes.assignAll(nuevos);
        participantesExisten.value = true;
        mensaje.value =
            'Importación exitosa: ${nuevos.length} participantes cargados';
      } else {
        mensaje.value = 'No se seleccionó archivo.';
      }
    } catch (e) {
      mensaje.value = 'Error al importar: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Función para iniciar el sorteo
  void iniciarSorteo() {
    if (participantes.isEmpty) {
      Get.snackbar(
        'Error',
        'No hay participantes para sortear',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Generar un índice aleatorio
    final random = Random();
    selectedIndex.value = random.nextInt(participantes.length);

    // Agregar el participante sorteado a la lista de sorteados
    final participanteSorteado = participantes[selectedIndex.value];
    if (!participantesSorteados.contains(participanteSorteado)) {
      participantesSorteados.add(participanteSorteado);
    }
  }

  // Función para limpiar los resultados del sorteo
  void limpiarSorteo() {
    participantesSorteados.clear();
    selectedIndex.value = 0;
  }
}