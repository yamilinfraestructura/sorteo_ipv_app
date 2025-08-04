import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:get/get.dart';
import '../controllers/manzanas_import_controller.dart';

class ImportarManzanasWidget extends StatelessWidget {
  const ImportarManzanasWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final importController = Get.put(ManzanasImportController());

    return Obx(() {
      return Column(
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.upload_file),
            label: const Text("Importar manzanas desde Excel"),
            onPressed: importController.isLoading.value
                ? null
                : () async {
                    await importController.importarDesdeExcel();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Importación completada ✅'),
                          backgroundColor: Colors.green,
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
