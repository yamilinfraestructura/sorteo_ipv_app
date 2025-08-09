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
        title: const Text('Historial de Posicionados'),
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
              'Aún no hay participantes sorteados.',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.ganadores.length,
          itemBuilder: (context, index) {
            final ganador = controller.ganadores[index];
            final isLastPositioned =
                index ==
                0; // El último posicionado está en el índice 0 (orden descendente)

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: isLastPositioned ? 8 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isLastPositioned
                    ? BorderSide(color: Colors.green.shade400, width: 3)
                    : BorderSide.none,
              ),
              child: Container(
                decoration: isLastPositioned
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.green.shade50, Colors.green.shade100],
                        ),
                      )
                    : null,
                child: ListTile(
                  leading: isLastPositioned
                      ? Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade400,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 20,
                          ),
                        )
                      : null,
                  title: Text(
                    ganador.nombreCompleto,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isLastPositioned
                          ? Colors.green.shade800
                          : Colors.black87,
                      fontSize: isLastPositioned ? 18 : 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mz: ${ganador.manzanaNombre} | Lote: ${ganador.loteNombre}',
                        style: TextStyle(
                          color: isLastPositioned
                              ? Colors.green.shade700
                              : Colors.black54,
                          fontWeight: isLastPositioned
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      Text(
                        'Fecha Sorteo: ${ganador.fechaSorteo != null ? DateFormat('dd/MM/yyyy HH:mm').format(ganador.fechaSorteo!) : 'N/A'}',
                        style: TextStyle(
                          color: isLastPositioned
                              ? Colors.green.shade600
                              : Colors.black54,
                          fontSize: isLastPositioned ? 14 : 12,
                        ),
                      ),
                      if (isLastPositioned) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade400,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'ÚLTIMO POSICIONADO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  onTap: () =>
                      _mostrarDetallesGanador(context, controller, ganador),
                ),
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
        title: 'Detalles del Posicionado',
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
      print('Error al mostrar detalles del posicionado: $e');
    }
  }
}
