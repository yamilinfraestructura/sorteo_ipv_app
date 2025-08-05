// participantes_import_controller.dart

// ignore_for_file: depend_on_referenced_packages, unnecessary_null_comparison

// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:excel/excel.dart' as excel;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ImportResult {
  final bool success;
  final String? error;

  ImportResult({required this.success, this.error});
}

class ParticipantesImportController extends GetxController {
  final isLoading = false.obs;
  final mensaje = ''.obs;
  final participantes = <Map<String, dynamic>>[].obs;

  Future<ImportResult> importarDesdeExcel() async {
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
        final excelFile = excel.Excel.decodeBytes(bytes);
        final sheet = excelFile.tables.values.first;

        if (sheet == null) {
          return ImportResult(
            success: false,
            error: 'No se encontró hoja en el archivo.',
          );
        }

        List<Map<String, dynamic>> nuevos = [];
        int duplicados = 0;

        for (int i = 1; i < sheet.maxRows; i++) {
          final row = sheet.row(i);
          if (row.isEmpty || row[3] == null || row[4] == null) continue;

          final dni = row[3]?.value?.toString() ?? '';
          final data = {
            'nro_para_sorteo': row[0]?.value?.toString() ?? '',
            'orden_sorteado': row[1]?.value?.toString() ?? '',
            'nro_inscripcion': row[2]?.value?.toString() ?? '',
            'dni': dni,
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

            'idSorteo': 'sorteo_2025_01',
            'haSidoSorteado': false,
            'timestampInscripcion': FieldValue.serverTimestamp(),
            'estado': 'pendiente',
          };

          final query = await FirebaseFirestore.instance
              .collection('participantes')
              .where('dni', isEqualTo: dni)
              .limit(1)
              .get();

          if (query.docs.isNotEmpty) {
            duplicados++;
            if (duplicados == 1) {
              Get.snackbar(
                'Duplicado',
                'Algunos DNIs ya existen en Firebase',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orange.shade100,
              );
            }
            continue;
          }

          // 🔁 NUEVO: crear el documento y obtener su ID
          final docRef = await FirebaseFirestore.instance
              .collection('participantes')
              .add(data);

          // 🔁 NUEVO: actualizar el campo id_participante
          await docRef.update({'id_participante': docRef.id});

          // 🔁 NUEVO: agregar el id al mapa antes de almacenarlo localmente
          final dataConId = Map<String, dynamic>.from(data);
          dataConId['id_participante'] = docRef.id;

          nuevos.add(dataConId);
        }

        participantes.assignAll(nuevos);
        mensaje.value =
            'Importación exitosa: ${nuevos.length} participantes.' +
            (duplicados > 0 ? ' ($duplicados duplicados omitidos)' : '');

        return ImportResult(success: true);
      } else {
        return ImportResult(success: false, error: 'No se seleccionó archivo.');
      }
    } catch (e, st) {
      debugPrint('Error al importar: $e\n$st');
      mensaje.value = 'Error al importar: ${e.toString()}';
      return ImportResult(success: false, error: e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
