// lib/controllers/sorteo_controller.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sorteo_ipv_app/src/data/models/participantes_model.dart';
import 'package:sorteo_ipv_app/src/domain/models/manzana_model.dart';

class SorteoController extends GetxController {
  // Observables para manejar el estado
  var participantesDisponibles = <ParticipanteModel>[].obs;
  var manzanasDisponibles = <ManzanaModel>[].obs;
  var participanteGanador = Rx<ParticipanteModel?>(null);
  var manzanaGanadora = Rx<ManzanaModel?>(null);
  var isLoading = false.obs;
  // Nuevos observables para el efecto de "giro"
  var isSpinning = false.obs; // Indica si la animación de giro está activa
  var currentSpinningParticipantName =
      ''.obs; // Nombre que se muestra durante el giro
  var currentSpinningManzanaName =
      ''.obs; // Manzana que se muestra durante el giro

  @override
  void onInit() {
    super.onInit();
    fetchDatosParaSorteo();
  }

  // --- Método para obtener los datos de Firestore ---
  Future<void> fetchDatosParaSorteo() async {
    try {
      isLoading.value = true;

      // Obtener participantes que no han sido sorteados
      final participantesSnapshot = await FirebaseFirestore.instance
          .collection('participantes')
          .where('haSidoSorteado', isEqualTo: false)
          .get();

      participantesDisponibles.value = participantesSnapshot.docs
          .map((doc) => ParticipanteModel.fromMap(doc.data(), id: doc.id))
          .toList();

      // OBTENER MANZANAS DISPONIBLES (donde 'disponible' es false)
      final manzanasSnapshot = await FirebaseFirestore.instance
          .collection('manzanas')
          .where('disponible', isEqualTo: false)
          .get();

      manzanasDisponibles.value = manzanasSnapshot.docs
          .map((doc) => ManzanaModel.fromMap(doc.id, doc.data()))
          .toList();

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Hubo un problema al cargar los datos. Intenta de nuevo.',
      );
      print('Error al cargar datos: $e');
    }
  }

  // --- Método para simular el efecto de "giro" ---
  Future<void> _startSpinningAnimation() async {
    isSpinning.value = true; // Activamos el estado de giro
    final random = Random();
    int spinDurationMs = 3000; // Duración total del giro en milisegundos
    int updateIntervalMs = 100; // Intervalo de actualización de los nombres

    // Calcula cuántas actualizaciones haremos
    int numUpdates = spinDurationMs ~/ updateIntervalMs;

    for (int i = 0; i < numUpdates; i++) {
      // Si hay participantes, muestra un nombre aleatorio
      if (participantesDisponibles.isNotEmpty) {
        currentSpinningParticipantName.value =
            participantesDisponibles[random.nextInt(
                  participantesDisponibles.length,
                )]
                .nombreCompleto;
      } else {
        currentSpinningParticipantName.value =
            'Sin participantes'; // Mensaje si no hay más
      }

      // Si hay manzanas, muestra una manzana aleatoria
      if (manzanasDisponibles.isNotEmpty) {
        final randomManzana =
            manzanasDisponibles[random.nextInt(manzanasDisponibles.length)];
        currentSpinningManzanaName.value =
            'Manzana: ${randomManzana.manzana} - Lote: ${randomManzana.posicion}';
      } else {
        currentSpinningManzanaName.value =
            'Sin manzanas'; // Mensaje si no hay más
      }

      await Future.delayed(Duration(milliseconds: updateIntervalMs));
    }
    isSpinning.value = false; // Desactivamos el estado de giro al finalizar
  }

  // --- Método principal para realizar el sorteo ---
  // --- Método principal para realizar el sorteo ---
  void realizarSorteo() async {
    // AQUI ES DONDE AGREGAMOS LA VERIFICACIÓN INICIAL
    if (participantesDisponibles.isEmpty || manzanasDisponibles.isEmpty) {
      Get.defaultDialog(
        title: 'Sorteo Finalizado',
        middleText:
            'No quedan más participantes o manzanas disponibles para sortear.',
        textConfirm: 'Entendido',
        confirmTextColor: Colors.white,
        onConfirm: () {
          Get.back(); // Cierra el diálogo
        },
      );
      return; // Salimos de la función si no hay elementos
    }

    try {
      isLoading.value = true;
      participanteGanador.value = null; // Limpiar resultados anteriores
      manzanaGanadora.value = null; // Limpiar resultados anteriores

      // Iniciar la animación de "giro" antes de seleccionar al ganador real
      await _startSpinningAnimation();

      final random = Random();
      final participanteIndex = random.nextInt(participantesDisponibles.length);
      final manzanaIndex = random.nextInt(manzanasDisponibles.length);

      final ganador = participantesDisponibles[participanteIndex];
      final manzana = manzanasDisponibles[manzanaIndex];

      participanteGanador.value = ganador;
      manzanaGanadora.value = manzana;

      final batch = FirebaseFirestore.instance.batch();

      // 1. Marcar al participante como sorteado
      final participanteRef = FirebaseFirestore.instance
          .collection('participantes')
          .doc(ganador.id);
      batch.update(participanteRef, {
        'haSidoSorteado': true,
        'idSorteo': manzana.id,
      });

      // 2. MARCAR LA MANZANA COMO NO DISPONIBLE (ahora 'disponible' es true)
      final manzanaRef = FirebaseFirestore.instance
          .collection('manzanas')
          .doc(manzana.id);
      batch.update(manzanaRef, {'disponible': true});

      // 3. Registrar el ganador en la colección 'ganadores'
      final ganadoresRef = FirebaseFirestore.instance
          .collection('ganadores')
          .doc();
      batch.set(ganadoresRef, {
        'participanteId': ganador.id,
        'manzanaId': manzana.id,
        'nombreCompleto': ganador.nombreCompleto,
        'dni_ganador': ganador.dni, // ¡Guardamos el DNI del ganador!
        'manzanaNombre': manzana.manzana,
        'loteNombre': manzana.posicion,
        'fechaSorteo': FieldValue.serverTimestamp(),
      });

      // Ejecutar todas las operaciones del lote
      await batch.commit();

      // Eliminar los elementos de las listas locales
      participantesDisponibles.removeAt(participanteIndex);
      manzanasDisponibles.removeAt(manzanaIndex);

      isLoading.value = false;
      Get.snackbar(
        '¡Sorteo Exitoso!',
        'El sorteo ha sido completado y los datos actualizados.',
        snackPosition: SnackPosition.BOTTOM,
      );

      // AQUI ES DONDE AGREGAMOS LA VERIFICACIÓN DESPUÉS DE UN SORTEO EXITOSO
      if (participantesDisponibles.isEmpty || manzanasDisponibles.isEmpty) {
        // Añadimos un pequeño retraso para que el usuario vea el snackbar antes del diálogo
        Future.delayed(const Duration(seconds: 1), () {
          Get.defaultDialog(
            title: 'Sorteo Finalizado',
            middleText:
                'Se han sorteado todos los participantes o manzanas disponibles.',
            textConfirm: 'Entendido',
            confirmTextColor: Colors.white,
            onConfirm: () {
              Get.back(); // Cierra el diálogo
            },
          );
        });
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Hubo un problema al realizar el sorteo. Intenta de nuevo.',
      );
      print('Error en el sorteo: $e');
    }
  }

  // --- Método para resetear el sorteo (opcional) ---
  void resetearSorteo() {
    participanteGanador.value = null;
    manzanaGanadora.value = null;
    currentSpinningParticipantName.value = ''; // Limpiar nombres de giro
    currentSpinningManzanaName.value = ''; // Limpiar nombres de giro
    fetchDatosParaSorteo();
  }
}
