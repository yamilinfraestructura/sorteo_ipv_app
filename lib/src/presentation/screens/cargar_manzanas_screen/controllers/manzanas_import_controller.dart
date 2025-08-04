// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:excel/excel.dart' as excel;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManzanasImportController extends GetxController {
  final isLoading = false.obs;
  final mensaje = ''.obs;
  final manzanas = <Map<String, dynamic>>[].obs;

  Future<void> importarDesdeExcel() async {
    isLoading.value = true;
    mensaje.value = '';
    manzanas.clear();

    debugPrint('👉 Iniciando importación de manzanas desde Excel');

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result == null || result.files.single.path == null) {
        debugPrint('! No se seleccionó archivo o está vacío');
        mensaje.value = 'No se seleccionó archivo.';
        return;
      }

      final path = result.files.single.path!;
      final bytes = await File(path).readAsBytes();
      final excelFile = excel.Excel.decodeBytes(bytes);
      final sheet = excelFile.tables.values.first;

      if (sheet == null) {
        mensaje.value = 'No se encontró hoja en el archivo.';
        return;
      }

      int registrosAgregados = 0;
      int errores = 0;

      for (int i = 1; i < sheet.maxRows; i++) {
        final row = sheet.row(i);
        if (row.length < 4) continue;

        final nombreManzana = row[0]?.value?.toString().trim();
        final posicion = row[1]?.value?.toString().trim();
        final nc = row[2]?.value?.toString().trim() ?? '';
        final geoposicion =
            row[3]?.value?.toString().trim() ?? 'Sin coordenadas';

        if (nombreManzana == null ||
            nombreManzana.isEmpty ||
            posicion == null ||
            posicion.isEmpty) {
          errores++;
          continue;
        }

        final data = {
          'manzana': nombreManzana,
          'posicion': posicion,
          'NC': nc,
          'geoposicion': geoposicion,
          'disponible': false, // ← campo nuevo
          'timestamp': FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance
            .collection('manzanas')
            .doc('${nombreManzana}_$posicion') // combinamos para que sea único
            .set(data);

        manzanas.add(data);
        registrosAgregados++;
      }

      mensaje.value =
          'Importación completada: $registrosAgregados registros agregados. '
          '${errores > 0 ? '$errores filas con errores fueron omitidas.' : ''}';

      if (registrosAgregados > 0) {
        Get.snackbar(
          'Importación exitosa',
          mensaje.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
        );
      }
    } catch (e, st) {
      debugPrint('❌ Error al importar manzanas: $e\n$st');
      mensaje.value = 'Error al importar: ${e.toString()}';
      Get.snackbar(
        'Error',
        mensaje.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      isLoading.value = false;
      debugPrint('🛑 Proceso de importación finalizado');
    }
  }
}
