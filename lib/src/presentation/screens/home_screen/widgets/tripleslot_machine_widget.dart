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

    ever(tripleCtrl.cargando, (loading) {
      if (loading == false) {
        inicializarControladores();
      }
    });
  }

  void inicializarControladores() {
    if (tripleCtrl.manzanaYPosicionesDisponibles.isEmpty) {
      print('No hay lotes cargados para el sorteo.');
      return;
    }

    ctrlParticipante = Get.put(
      SorteadorController(items: tripleCtrl.participantes),
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
      return;
    }

    await ctrlParticipante!.startAutomaticDraw();
    await Future.delayed(const Duration(milliseconds: 600));
    await ctrlManzanaYPosicion!.startAutomaticDraw();

    final index = ctrlManzanaYPosicion!.selectedIndex.value;
    if (index == null) {
      print('No se ha seleccionado manzana y posición aún.');
      return;
    }

    final seleccion = ctrlManzanaYPosicion!.items[index];
    final partes = seleccion.split(' - ');
    if (partes.length != 2) {
      print('Formato inválido de selección: $seleccion');
      return;
    }

    final manzana = partes[0].trim();
    final posicion = partes[1].trim();

    final participanteIndex = ctrlParticipante!.selectedIndex.value;
    if (participanteIndex == null) {
      print('No se ha seleccionado participante aún.');
      return;
    }

    final nombreParticipante = ctrlParticipante!.items[participanteIndex];

    final lote = tripleCtrl.lotesPorManzana[manzana]?.firstWhere(
      (l) => l.posicion == posicion,
      orElse: () => null!,
    );

    if (lote == null) {
      print('No se encontró el lote seleccionado: $manzana - $posicion');
      return;
    }

    await tripleCtrl.registrarGanador(
      nombreParticipante: nombreParticipante,
      manzanaSeleccionada: manzana,
      loteSeleccionado: lote,
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
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollEndNotification &&
                    !controller.isScrolling.value) {
                  Future.delayed(const Duration(milliseconds: 800), () {
                    if (!controller.isScrolling.value) {
                      controller.stopManualScroll();
                    }
                  });
                }
                return false;
              },
              child: ListView.builder(
                controller: controller.scrollController,
                itemCount:
                    controller.items.length *
                    controller.listMultiplicationFactor,
                itemExtent: controller.itemHeight,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final actualIndex = index % controller.items.length;
                  final isSelected =
                      selected != null && selected == actualIndex;

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

      return Column(
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
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
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

            if (participante != null && seleccion != null) {
              return Text(
                'Ganador:\n${ctrlParticipante!.items[participante]}, '
                '${ctrlManzanaYPosicion!.items[seleccion]}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
        ],
      );
    });
  }
}
