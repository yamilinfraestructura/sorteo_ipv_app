
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:get/get.dart';
import '../controllers/carga_participantes_controller.dart';

class SorteadorListaWidget extends StatefulWidget {
  final double widthScreen;

  const SorteadorListaWidget({super.key, required this.widthScreen});

  @override
  State<SorteadorListaWidget> createState() => _SorteadorListaWidgetState();
}

class _SorteadorListaWidgetState extends State<SorteadorListaWidget> {
  final CargaParticipantesController controller = Get.put(CargaParticipantesController());
  
  @override
  void initState() {
    super.initState();
    // Cargar participantes al inicializar el widget
    controller.cargarParticipantes();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.widthScreen * 0.8,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Sorteo de Participantes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          
          // Información de participantes cargados
          Obx(() => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Participantes cargados: ${controller.participantes.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (controller.participantes.isNotEmpty)
                  Icon(Icons.check_circle, color: Colors.green[600]),
              ],
            ),
          )),
          
          const SizedBox(height: 30),
          
          // Ruleta de la fortuna
          Obx(() {
            if (controller.participantes.isEmpty) {
              return Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 50, color: Colors.grey),
                      SizedBox(height: 10),
                      Text(
                        'No hay participantes cargados',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      Text(
                        'Importa participantes para comenzar',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            return SizedBox(
              height: 300,
              width: 400,
              child: FortuneBar(
                selected: controller.selectedIndex.value,
                items: controller.participantes.map((participante) {
                  return FortuneItem(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: _getRandomColor(controller.participantes.indexOf(participante)),
                            radius: 20,
                            child: Text(
                              participante.nombre.isNotEmpty ? participante.nombre[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  participante.nombre,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'DNI: ${participante.dni}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    style: FortuneItemStyle(
                      color: Colors.white,
                      borderColor: Colors.grey[300]!,
                      borderWidth: 1,
                    ),
                  );
                }).toList(),
                height: 80, // Altura de cada elemento
                visibleItemCount: 3, // Cuántos elementos son visibles al mismo tiempo
                onAnimationEnd: () {
                  if (controller.participantes.isNotEmpty) {
                    final ganador = controller.participantes[controller.selectedIndex.value];
                    _mostrarGanador(ganador.nombre);
                  }
                },
              ),
            );
          }),
          
          const SizedBox(height: 30),
          
          // Botones de control
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: controller.participantes.isEmpty ? null : () {
                  controller.iniciarSorteo();
                },
                icon: const Icon(Icons.casino),
                label: const Text('Sortear'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  controller.cargarParticipantes();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Recargar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          )),
          
          const SizedBox(height: 20),
          
          // Lista de participantes sorteados
          Obx(() {
            if (controller.participantesSorteados.isEmpty) {
              return const SizedBox.shrink();
            }
            
            return Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resultados del Sorteo:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: controller.participantesSorteados.length,
                        itemBuilder: (context, index) {
                          final participante = controller.participantesSorteados[index];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue[600],
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(participante.nombre),
                              subtitle: Text('DNI: ${participante.dni}'),
                              trailing: const Icon(Icons.emoji_events, color: Colors.amber),
                            ),
                          );
                        },
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        controller.limpiarSorteo();
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text('Limpiar Resultados'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _getRandomColor(int index) {
    final colors = [
      Colors.red[400]!,
      Colors.blue[400]!,
      Colors.green[400]!,
      Colors.orange[400]!,
      Colors.purple[400]!,
      Colors.teal[400]!,
      Colors.indigo[400]!,
      Colors.pink[400]!,
    ];
    return colors[index % colors.length];
  }

  void _mostrarGanador(String nombre) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber, size: 30),
              SizedBox(width: 10),
              Text('¡Ganador!'),
            ],
          ),
          content: Text(
            '¡Felicitaciones $nombre!\nHas sido seleccionado en el sorteo.',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
