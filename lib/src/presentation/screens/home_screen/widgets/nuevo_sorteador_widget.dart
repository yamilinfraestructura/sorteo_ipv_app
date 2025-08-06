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
                  style: const TextStyle(fontSize: 18),
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
                  ), // Tamaño de fuente mejorado
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Manzana: ${controller.currentSpinningManzanaName.value}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ), // Tamaño de fuente mejorado
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                const CircularProgressIndicator(), // Indicador visual de que algo está pasando
              ],
            );
          }

          // Si hay un ganador, muestra los resultados
          if (controller.participanteGanador.value != null &&
              controller.manzanaGanadora.value != null) {
            // Programar el reseteo automático después de un breve retraso
            // Esto permite al usuario ver el resultado antes de que la pantalla se prepare para el siguiente sorteo
            Future.delayed(const Duration(seconds: 3), () {
              // Puedes ajustar este tiempo
              if (controller.participanteGanador.value != null) {
                // Solo resetear si aún hay un ganador mostrado
                controller.resetearSorteo();
              }
            });

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '¡Ganador Sorteado!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text(
                  'Participante: ${controller.participanteGanador.value!.nombreCompleto}',
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ), // Tamaño de fuente mejorado
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Manzana Asignada: ${controller.manzanaGanadora.value!.manzana} - Lote: ${controller.manzanaGanadora.value!.posicion}', // "Posición" cambiado a "Lote"
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ), // Tamaño de fuente mejorado
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Eliminamos el botón "Realizar Otro Sorteo"
                // El reseteo ahora es automático
              ],
            );
          }

          // Interfaz principal para realizar el sorteo
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Listos para sortear',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40), // Espacio ajustado
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
            ],
          );
        }),
      ),
    );
  }
}
