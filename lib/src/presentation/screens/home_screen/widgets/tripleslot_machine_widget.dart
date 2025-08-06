// ignore_for_file: depend_on_referenced_packages, unused_local_variable
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sorteo_ipv_app/src/presentation/screens/home_screen/controllers/triple_sorteador_controller.dart';
import '../controllers/controller.dart';

class TripleSlotMachineWidget extends StatefulWidget {
  const TripleSlotMachineWidget({super.key});

  @override
  State<TripleSlotMachineWidget> createState() =>
      _TripleSlotMachineWidgetState();
}

class _TripleSlotMachineWidgetState extends State<TripleSlotMachineWidget> {
  final TripleSorteadorController tripleCtrl = Get.put(
    TripleSorteadorController(),
  );

  SorteadorController? ctrlParticipante;
  SorteadorController? ctrlManzanaYPosicion;

  @override
  void initState() {
    super.initState();

    // Configurar el callback para actualizar los controladores
    tripleCtrl.onDatosActualizados = _reinicializarControladores;

    ever(tripleCtrl.cargando, (loading) {
      if (loading == false) {
        inicializarControladores();
      }
    });
  }

  void _reinicializarControladores() {
    // Pequeño delay para que la actualización sea más suave
    Future.delayed(const Duration(milliseconds: 500), () {
      // Validar que haya participantes disponibles
      if (tripleCtrl.participantes.isEmpty) {
        print('No hay participantes disponibles para actualizar');
        return;
      }

      // Validar que haya manzanas disponibles
      if (tripleCtrl.manzanaYPosicionesDisponibles.isEmpty) {
        print('No hay manzanas disponibles para actualizar');
        return;
      }

      // Actualizar los items de los controladores existentes en lugar de recrearlos
      if (ctrlParticipante != null) {
        final nuevosParticipantes = tripleCtrl.participantes
            .map((p) => p.nombreCompleto)
            .toList();

        // Verificar que la lista no esté vacía
        if (nuevosParticipantes.isNotEmpty) {
          ctrlParticipante!.actualizarItems(nuevosParticipantes);
        }
      }

      if (ctrlManzanaYPosicion != null) {
        // Verificar que la lista no esté vacía
        if (tripleCtrl.manzanaYPosicionesDisponibles.isNotEmpty) {
          ctrlManzanaYPosicion!.actualizarItems(
            tripleCtrl.manzanaYPosicionesDisponibles,
          );
        }
      }

      // Si no hay controladores o no hay datos, inicializar
      if (ctrlParticipante == null || ctrlManzanaYPosicion == null) {
        inicializarControladores();
      }
    });
  }

  void inicializarControladores() {
    if (tripleCtrl.manzanaYPosicionesDisponibles.isEmpty) {
      print('No hay lotes cargados para el sorteo.');
      return;
    }

    if (tripleCtrl.participantes.isEmpty) {
      print('No hay participantes disponibles para el sorteo.');
      return;
    }

    ctrlParticipante = Get.put(
      SorteadorController(
        items: tripleCtrl.participantes.map((p) => p.nombreCompleto).toList(),
      ),
      tag: 'participante',
    );

    ctrlManzanaYPosicion = Get.put(
      SorteadorController(items: tripleCtrl.manzanaYPosicionesDisponibles),
      tag: 'manzanaYPosicion',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrlParticipante?.jumpToInitialOffset();
      ctrlManzanaYPosicion?.jumpToInitialOffset();
    });
  }

  Future<void> iniciarSorteo() async {
    if (ctrlParticipante == null || ctrlManzanaYPosicion == null) {
      print('Controladores no inicializados.');
      Get.snackbar(
        'Error',
        'Los controladores no están inicializados',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    await ctrlParticipante!.startAutomaticDraw();
    await Future.delayed(const Duration(milliseconds: 600));
    await ctrlManzanaYPosicion!.startAutomaticDraw();

    final index = ctrlManzanaYPosicion!.selectedIndex.value;
    if (index == null) {
      print('No se ha seleccionado manzana y posición aún.');
      Get.snackbar(
        'Error',
        'No se ha seleccionado manzana y posición',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    final seleccion = ctrlManzanaYPosicion!.items[index];
    final partes = seleccion.split(' - ');
    if (partes.length != 2) {
      print('Formato inválido de selección: $seleccion');
      Get.snackbar(
        'Error',
        'Formato inválido de selección de manzana',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    final manzana = partes[0].trim();
    final posicion = partes[1].trim();

    final participanteIndex = ctrlParticipante!.selectedIndex.value;
    if (participanteIndex == null) {
      print('No se ha seleccionado participante aún.');
      Get.snackbar(
        'Error',
        'No se ha seleccionado participante',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    final participanteSeleccionado =
        tripleCtrl.participantes[participanteIndex];

    final lote = tripleCtrl.lotesPorManzana[manzana]?.firstWhere(
      (l) => l.posicion == posicion,
      orElse: () => null!,
    );

    if (lote == null) {
      print('No se encontró el lote seleccionado: $manzana - $posicion');
      Get.snackbar(
        'Error',
        'No se encontró el lote seleccionado',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    // Validar antes de registrar
    if (!tripleCtrl.validarGanador(
      participante: participanteSeleccionado,
      lote: lote,
    )) {
      Get.snackbar(
        'Error de Validación',
        'El participante o lote ya han sido sorteados',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    await tripleCtrl.registrarGanador(
      participanteSeleccionado: participanteSeleccionado,
      manzanaSeleccionada: manzana,
      loteSeleccionado: lote,
    );

    // Mostrar mensaje de éxito
    Get.snackbar(
      '¡Éxito!',
      'Ganador registrado correctamente',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    Get.delete<SorteadorController>(tag: 'participante');
    Get.delete<SorteadorController>(tag: 'manzanaYPosicion');
    super.dispose();
  }

  Widget _buildSlot(SorteadorController? controller, {double width = 180}) {
    if (controller == null) {
      return Container(
        width: width,
        height: 60 * 5,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 2),
          borderRadius: BorderRadius.circular(14),
          color: Colors.grey.shade200,
        ),
        child: const Text('Cargando...', style: TextStyle(color: Colors.grey)),
      );
    }

    return Obx(() {
      final selected = controller.selectedIndex.value;
      return Container(
        width: width,
        height: controller.itemHeight * controller.visibleItems,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          children: [
            ListView.builder(
              controller: controller.scrollController,
              itemCount:
                  controller.items.length * controller.listMultiplicationFactor,
              itemExtent: controller.itemHeight,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final actualIndex = index % controller.items.length;
                final isSelected = selected != null && selected == actualIndex;

                return Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.amber.shade200 : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? Colors.amber : Colors.transparent,
                      width: isSelected ? 3 : 0,
                    ),
                  ),
                  child: Text(
                    controller.items[actualIndex],
                    style: TextStyle(
                      fontSize: isSelected ? 24 : 18,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
            Center(
              child: Container(
                height: controller.itemHeight,
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color: Colors.red.shade700,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (tripleCtrl.cargando.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (tripleCtrl.manzanaYPosicionesDisponibles.isEmpty) {
        return const Center(
          child: Text(
            'No hay lotes disponibles para el sorteo.',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
            textAlign: TextAlign.center,
          ),
        );
      }

      if (tripleCtrl.participantes.isEmpty) {
        return const Center(
          child: Text(
            'No hay participantes disponibles para el sorteo.',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
            textAlign: TextAlign.center,
          ),
        );
      }

      return Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSlot(ctrlParticipante, width: 180),
                    _buildSlot(ctrlManzanaYPosicion, width: 220),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: iniciarSorteo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                  shadowColor: Colors.black45,
                  textStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text("START"),
              ),
              const SizedBox(height: 30),
              Obx(() {
                final participante = ctrlParticipante?.selectedIndex.value;
                final seleccion = ctrlManzanaYPosicion?.selectedIndex.value;

                final participantesList = ctrlParticipante?.items ?? [];
                final manzanasList = ctrlManzanaYPosicion?.items ?? [];
                final participanteValido =
                    participante != null &&
                    participante >= 0 &&
                    participante < participantesList.length;
                final seleccionValida =
                    seleccion != null &&
                    seleccion >= 0 &&
                    seleccion < manzanasList.length;

                if (participanteValido && seleccionValida) {
                  final participanteSeleccionado =
                      tripleCtrl.participantes[participante];
                  final manzanaSeleccionada =
                      tripleCtrl.manzanaYPosicionesDisponibles[seleccion];

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Participante Seleccionado:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          participanteSeleccionado.nombreCompleto,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Lote Seleccionado:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          manzanaSeleccionada,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                // Mensaje si el índice no es válido
                return Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, color: Colors.red.shade400),
                      const SizedBox(width: 8),
                      const Text(
                        'El resultado anterior ya no es válido. Realiza un nuevo sorteo.',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
          // Indicador de actualización
          if (tripleCtrl.actualizando.value)
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Actualizando...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }
}
