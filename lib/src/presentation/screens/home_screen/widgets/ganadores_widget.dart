import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sorteo_ipv_app/src/data/models/participantes_model.dart';
import 'package:sorteo_ipv_app/src/domain/models/ganador_model.dart';
import 'package:sorteo_ipv_app/src/domain/models/manzana_model.dart';
import 'package:sorteo_ipv_app/src/presentation/screens/home_screen/controllers/ganador_controller.dart';
import 'package:intl/intl.dart';

class GanadoresWidget extends StatelessWidget {
  const GanadoresWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicializar el controlador
    final GanadoresController controller = Get.put(GanadoresController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Ganadores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            // ¡Aquí está el cambio! Ahora llamamos a listenToGanadores()
            onPressed: () => controller.listenToGanadores(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.ganadores.isEmpty) {
          return const Center(
            child: Text(
              'Aún no hay ganadores sorteados.',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.ganadores.length,
          itemBuilder: (context, index) {
            final ganador = controller.ganadores[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(
                  ganador.nombreCompleto,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Mz: ${ganador.manzanaNombre} | Lote: ${ganador.loteNombre}\nFecha Sorteo: ${ganador.fechaSorteo != null ? DateFormat('dd/MM/yyyy HH:mm').format(ganador.fechaSorteo!) : 'N/A'}',
                ),
                onTap: () =>
                    _mostrarDetallesGanador(context, controller, ganador),
              ),
            );
          },
        );
      }),
    );
  }

  void _mostrarDetallesGanador(
    BuildContext context,
    GanadoresController controller,
    GanadorModel ganador,
  ) async {
    // Muestra un indicador de carga mientras se obtienen los detalles
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final detalles = await controller.obtenerDetalles(ganador);
      final ParticipanteModel participante = detalles['participante'];
      final ManzanaModel manzana = detalles['manzana'];

      Get.back(); // Cierra el indicador de carga

      // Muestra los detalles en un diálogo
      Get.defaultDialog(
        title: 'Detalles del Ganador',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Participante: ${participante.nombreCompleto}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('DNI: ${participante.dni}'),
            const Divider(),
            Text(
              'Manzana: ${manzana.manzana}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Posición: ${manzana.posicion}'),
            Text('Coordenadas: ${manzana.geoposicion}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cerrar')),
        ],
      );
    } catch (e) {
      Get.back(); // Cierra el indicador de carga
      Get.snackbar('Error', 'No se pudieron obtener los detalles completos.');
      print('Error al mostrar detalles del ganador: $e');
    }
  }
}
