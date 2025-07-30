// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sorteo_ipv_app/src/presentation/screens/home_screen/controllers/carga_participantes_controller.dart';
import 'package:sorteo_ipv_app/src/domain/models/participantes_model.dart';

class CargaParticipantesScreen extends StatefulWidget {
  const CargaParticipantesScreen({super.key});

  @override
  State<CargaParticipantesScreen> createState() =>
      _CargaParticipantesScreenState();
}

class _CargaParticipantesScreenState extends State<CargaParticipantesScreen> {
  final CargaParticipantesController controller = Get.put(
    CargaParticipantesController(),
  );
  final String idSorteoActual = "sorteo_2024"; // Puedes hacer esto dinámico

  @override
  void initState() {
    super.initState();
    // Verificar si ya existen participantes al iniciar
    controller.verificarParticipantesExistentes(idSorteoActual).then((existe) {
      if (existe) {
        controller.obtenerParticipantes(idSorteoActual);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cargar Participantes'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Botón de carga
            Obx(
              () => ElevatedButton.icon(
                onPressed: controller.isLoading.value
                    ? null
                    : () => _mostrarDialogoConfirmacion(),
                icon: controller.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload_file),
                label: Text(
                  controller.isLoading.value
                      ? 'Cargando...'
                      : 'Cargar Excel de Participantes',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Mensaje de estado
            Obx(
              () => controller.mensaje.value.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: controller.mensaje.value.contains('Error')
                            ? Colors.red.shade100
                            : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: controller.mensaje.value.contains('Error')
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                      child: Text(
                        controller.mensaje.value,
                        style: TextStyle(
                          color: controller.mensaje.value.contains('Error')
                              ? Colors.red.shade800
                              : Colors.green.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 20),

            // Título de la lista
            Text(
              'Participantes Cargados (${controller.participantes.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // Lista de participantes
            Expanded(
              child: Obx(
                () => controller.participantes.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay participantes cargados',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: controller.participantes.length,
                        itemBuilder: (context, index) {
                          final participante = controller.participantes[index];
                          return _buildParticipanteCard(participante);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipanteCard(ParticipanteModel participante) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            participante.nroParaSorteo.isEmpty
                ? 'N/A'
                : participante.nroParaSorteo,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          participante.nombreCompleto,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DNI: ${participante.dni}'),
            if (participante.localidad.isNotEmpty)
              Text('Localidad: ${participante.localidad}'),
          ],
        ),
        trailing: participante.nroInscripcion.isNotEmpty
            ? Chip(
                label: Text(
                  'Inscr: ${participante.nroInscripcion}',
                  style: const TextStyle(fontSize: 10),
                ),
                backgroundColor: Colors.orange.shade100,
              )
            : null,
        isThreeLine: true,
      ),
    );
  }

  void _mostrarDialogoConfirmacion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Carga'),
          content: controller.participantesExisten.value
              ? const Text(
                  'Ya existen participantes cargados para este sorteo. ¿Desea visualizarlos?',
                )
              : const Text(
                  '¿Está seguro que desea cargar los participantes desde el archivo Excel?',
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (controller.participantesExisten.value) {
                  controller.obtenerParticipantes(idSorteoActual);
                } else {
                  controller.importarExcel(idSorteoActual);
                }
              },
              child: Text(
                controller.participantesExisten.value
                    ? 'Ver Participantes'
                    : 'Cargar Excel',
              ),
            ),
          ],
        );
      },
    );
  }
}
