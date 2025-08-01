import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:get/get.dart';
import '../controllers/participantes_import_controller.dart';

class ImportarParticipantesWidget extends StatelessWidget {
  const ImportarParticipantesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final importController = Get.put(ParticipantesImportController());

    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.upload_file),
            label: const Text("Importar participantes desde Excel"),
            onPressed: importController.isLoading.value
                ? null
                : () async {
                    final result = await importController.importarDesdeExcel();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result.success
                                ? 'Participantes importados con éxito ✅'
                                : 'Error al importar: ${result.error}',
                          ),
                          backgroundColor: result.success
                              ? Colors.green
                              : Colors.red,
                        ),
                      );
                    }
                  },
          ),
          const SizedBox(height: 20),
          if (importController.isLoading.value)
            const CircularProgressIndicator(),
        ],
      );
    });
  }
}
