// ignore_for_file: depend_on_referenced_packages

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class CargaParticipantesController extends GetxController {
  var isLoading = false.obs;
  var mensaje = ''.obs;
  var participantes = <Map<String, dynamic>>[].obs;

  Future<void> importarExcel(String idSorteoActual) async {
    isLoading.value = true;
    mensaje.value = '';
    try {
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
        List<Map<String, dynamic>> nuevos = [];
        int duplicados = 0;
        List<String> dnisExcel = [];
        for (int i = 1; i < sheet.maxRows; i++) {
          final row = sheet.row(i);
          if (row.isEmpty || row[3] == null) continue;
          dnisExcel.add(row[3]?.value?.toString() ?? '');
        }
        // Verificar duplicados en Firestore
        var snapshot = await FirebaseFirestore.instance
            .collection('participantes')
            .where('dni', whereIn: dnisExcel)
            .where('idSorteo', isEqualTo: idSorteoActual)
            .get();
        var dnisFirestore = snapshot.docs
            .map((doc) => doc['dni'] as String)
            .toSet();

        for (int i = 1; i < sheet.maxRows; i++) {
          final row = sheet.row(i);
          if (row.isEmpty || row[3] == null || row[4] == null) continue;
          final data = {
            'nro_para_sorteo': row[0]?.value?.toString() ?? '',
            'orden_sorteado': row[1]?.value?.toString() ?? '',
            'nro_inscripcion': row[2]?.value?.toString() ?? '',
            'dni': row[3]?.value?.toString() ?? '',
            'apellido': row[4]?.value?.toString() ?? '',
            'nombre': row[5]?.value?.toString() ?? '',
            'sexo': row[6]?.value?.toString() ?? '',
            'f_nac': row[7]?.value?.toString() ?? '',
            'ingreso_mensual': row[8]?.value?.toString() ?? '',
            'estudios': row[9]?.value?.toString() ?? '',
            'f_fall': row[10]?.value?.toString() ?? '',
            'f_baja': row[11]?.value?.toString() ?? '',
            'departamento': row[12]?.value?.toString() ?? '',
            'localidad': row[13]?.value?.toString() ?? '',
            'barrio': row[14]?.value?.toString() ?? '',
            'domicilio': row[15]?.value?.toString() ?? '',
            'tel': row[16]?.value?.toString() ?? '',
            'cant_ocupantes': row[17]?.value?.toString() ?? '',
            'descripcion1': row[18]?.value?.toString() ?? '',
            'descripcion2': row[19]?.value?.toString() ?? '',
            'grupreferencial': row[20]?.value?.toString() ?? '',
            'preferencial_ficha': row[21]?.value?.toString() ?? '',
            'ficha': row[22]?.value?.toString() ?? '',
            'f_alta': row[23]?.value?.toString() ?? '',
            'fmodif': row[24]?.value?.toString() ?? '',
            'f_baja2': row[25]?.value?.toString() ?? '',
            'expediente': row[26]?.value?.toString() ?? '',
            'reemp': row[27]?.value?.toString() ?? '',
            'estado_txt': row[28]?.value?.toString() ?? '',
            'circuitoipv_txt': row[29]?.value?.toString() ?? '',
            'circuitoipv_nota': row[30]?.value?.toString() ?? '',
            'idSorteo': idSorteoActual,
          };
          if (dnisFirestore.contains(data['dni'])) {
            duplicados++;
            continue;
          }
          await FirebaseFirestore.instance
              .collection('participantes')
              .add(data);
          nuevos.add(data);
        }
        participantes.assignAll(nuevos);
        mensaje.value =
            'Importación exitosa: ${nuevos.length} participantes.${duplicados > 0 ? ' ($duplicados duplicados omitidos)' : ''}';
      } else {
        mensaje.value = 'No se seleccionó archivo.';
      }
    } catch (e) {
      mensaje.value = 'Error al importar: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }
}
