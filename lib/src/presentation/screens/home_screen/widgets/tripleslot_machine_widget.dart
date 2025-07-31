// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/controller.dart';

class TripleSlotMachineWidget extends StatefulWidget {
  const TripleSlotMachineWidget({super.key});

  @override
  State<TripleSlotMachineWidget> createState() =>
      _TripleSlotMachineWidgetState();
}

class _TripleSlotMachineWidgetState extends State<TripleSlotMachineWidget> {
  final participantes = List.generate(10, (i) => 'Participante ${i + 1}');
  final manzanas = List.generate(
    5,
    (i) => 'Manzana ${String.fromCharCode(65 + i)}',
  );
  final lotes = List.generate(8, (i) => 'Lote ${i + 1}');

  late final SorteadorController ctrlParticipante;
  late final SorteadorController ctrlManzana;
  late final SorteadorController ctrlLote;

  @override
  void initState() {
    super.initState();
    ctrlParticipante = Get.put(
      SorteadorController(items: participantes),
      tag: 'participante',
    );
    ctrlManzana = Get.put(SorteadorController(items: manzanas), tag: 'manzana');
    ctrlLote = Get.put(SorteadorController(items: lotes), tag: 'lote');

    // Esperar a que el widget se construya para hacer jumpToInitialOffset
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrlParticipante.jumpToInitialOffset();
      ctrlManzana.jumpToInitialOffset();
      ctrlLote.jumpToInitialOffset();
    });
  }

  Future<void> iniciarSorteo() async {
    await ctrlParticipante.startAutomaticDraw();
    await Future.delayed(const Duration(milliseconds: 500));
    await ctrlManzana.startAutomaticDraw();
    await Future.delayed(const Duration(milliseconds: 500));
    await ctrlLote.startAutomaticDraw();
  }

  @override
  void dispose() {
    Get.delete<SorteadorController>(tag: 'participante');
    Get.delete<SorteadorController>(tag: 'manzana');
    Get.delete<SorteadorController>(tag: 'lote');
    super.dispose();
  }

  Widget _buildSlot(SorteadorController controller) {
    return Obx(() {
      final selected = controller.selectedIndex.value;
      final isScrolling = controller.isScrolling.value;
      return Container(
        width: 120,
        height: controller.itemHeight * controller.visibleItems,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 2),
          borderRadius: BorderRadius.circular(12),
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
                  final selected = controller.selectedIndex.value;
                  final isSelected =
                      selected != null && selected == actualIndex;

                  return Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.amber.shade200 : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Colors.amber : Colors.transparent,
                        width: isSelected ? 3 : 0,
                      ),
                    ),
                    child: Text(
                      controller.items[actualIndex],
                      style: TextStyle(
                        fontSize: isSelected ? 22 : 16,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
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
    return SingleChildScrollView(
      // Evita overflow vertical
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: iniciarSorteo,
            child: const Text('Sortear Triple'),
          ),
          const SizedBox(height: 20),

          // Scroll horizontal para evitar overflow si no cabe el Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSlot(ctrlParticipante),
                    _buildSlot(ctrlManzana),
                    _buildSlot(ctrlLote),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Obx(() {
            final participante = ctrlParticipante.selectedIndex.value;
            final manzana = ctrlManzana.selectedIndex.value;
            final lote = ctrlLote.selectedIndex.value;

            if (participante != null && manzana != null && lote != null) {
              return Text(
                'Ganador: ${ctrlParticipante.items[participante]}, '
                '${ctrlManzana.items[manzana]}, '
                '${ctrlLote.items[lote]}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
        ],
      ),
    );
  }
}
