// lib/widgets/sorteo_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sorteo_ipv_app/src/presentation/screens/home_screen/controllers/nuevo_sorteador_controller.dart';

class SorteoWidget extends StatelessWidget {
  const SorteoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicializar el controlador
    final SorteoController controller = Get.put(SorteoController());

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        // Título de la AppBar con los contadores reactivos
        title: Obx(
          () => Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Sorteador de Manzanas y Lotes',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Participantes: ${controller.participantesDisponibles.length} | Manzanas: ${controller.manzanasDisponibles.length}',
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        ),
        //backgroundColor: Colors.amberAccent, // Color de AppBar original
        elevation: 0,
      ),
      body: Center(
        child: Obx(() {
          // Si está cargando datos iniciales (no el giro), muestra un indicador de progreso
          if (controller.isLoading.value && !controller.isSpinning.value) {
            return const CircularProgressIndicator();
          }

          // Si el sorteo está en curso (girando)
          if (controller.isSpinning.value) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '¡Realizando Sorteo!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text(
                  'Participante: ${controller.currentSpinningParticipantName.value}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Manzana: ${controller.currentSpinningManzanaName.value}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                const CircularProgressIndicator(),
              ],
            );
          }

          // Interfaz principal para realizar el sorteo y mostrar el último ganador
          // Ya no se usa la lógica del reseteo automático con Future.delayed
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Listos para sortear',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: controller.realizarSorteo,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 20,
                  ),
                ),
                child: const Text(
                  'Realizar Sorteo',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              // Aquí mostramos el último ganador solo si existe
              if (controller.participanteGanador.value != null &&
                  controller.manzanaGanadora.value != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade400,
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ÚLTIMO POSICIONADO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${controller.participanteGanador.value!.nombreCompleto}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'DNI: ${controller.participanteGanador.value!.dni}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'MANZANA: ${controller.manzanaGanadora.value!.manzana} - LOTE: ${controller.manzanaGanadora.value!.posicion}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}
