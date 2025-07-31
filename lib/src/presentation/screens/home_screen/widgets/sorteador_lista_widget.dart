import 'dart:async';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:get/get.dart';

import '../controllers/controller.dart';
// ignore: depend_on_referenced_packages

class SorteadorListaWidget extends StatefulWidget {
  const SorteadorListaWidget({super.key, required double widthScreen})
    : _widthScreen = widthScreen;

  final double _widthScreen;

  @override
  State<SorteadorListaWidget> createState() => _SorteadorListaWidgetState();
}

class _SorteadorListaWidgetState extends State<SorteadorListaWidget> {
  StreamController<int> selected = StreamController<int>();

  @override
  void dispose() {
    selected.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      // Centramos el widget en la pantalla
      child: SizedBox(
        height:
            MediaQuery.of(context).size.height *
            0.8, // Puedes ajustar la altura
        width: widget._widthScreen * 0.8, // Puedes ajustar el ancho
        child: CustomVerticalLottery(),
      ),
    );
  }
}

//Widget de Sorteo Vertical
// Este widget muestra una lista de participantes y permite seleccionar un ganador
class CustomVerticalLottery extends StatelessWidget {
  final SorteadorController controller = Get.put(
    SorteadorController(
      items: const [
        'Grogu',
        'Mace Windu',
        'Obi-Wan Kenobi',
        'Han Solo',
        'Luke Skywalker',
        'Darth Vader',
        'Yoda',
        'Ahsoka Tano',
        'Rolando Molina',
      ],
      itemHeight: 70.0,
      visibleItems: 5,
    ),
  );

  CustomVerticalLottery({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: controller.startAutomaticDraw,
            child: const Text('¡Sortear! (Automático)'),
          ),
          const SizedBox(height: 20),
          Container(
            height: controller.itemHeight * controller.visibleItems,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(15),
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
                          color: isSelected
                              ? Colors.green.shade200
                              : Colors.blueGrey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? Colors.green.shade700
                                : Colors.transparent,
                            width: isSelected ? 3.0 : 0.0,
                          ),
                        ),
                        child: Text(
                          controller.items[actualIndex],
                          style: TextStyle(
                            fontSize: isSelected ? 24 : 18,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.green.shade900
                                : Colors.black87,
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
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (controller.selectedIndex.value != null &&
              controller.selectedIndex.value != -1)
            Text(
              '¡El ganador es: ${controller.items[controller.selectedIndex.value!]}!',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
        ],
      ),
    );
  }
}

/*
class CustomVerticalLottery extends StatefulWidget {
  CustomVerticalLottery({super.key});

  final SorteadorController controller = Get.put(
    SorteadorController(
      items: const [
        'Grogu',
        'Mace Windu',
        'Obi-Wan Kenobi',
        'Han Solo',
        'Luke Skywalker',
        'Darth Vader',
        'Yoda',
        'Ahsoka Tano',
        'Rolando Molina',
      ],
      itemHeight: 70.0,
      visibleItems: 5,
    ),
  );

  @override
  State<CustomVerticalLottery> createState() => _CustomVerticalLotteryState();
}

class _CustomVerticalLotteryState extends State<CustomVerticalLottery> {
  SorteadorController get controller => widget.controller;

  @override
  void initState() {
    super.initState();

    // Esto asegura que el jumpTo se hace cuando el scrollController está listo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.jumpToInitialOffset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: controller.startAutomaticDraw,
            child: const Text('¡Sortear! (Automático)'),
          ),
          const SizedBox(height: 20),
          Container(
            height: controller.itemHeight * controller.visibleItems,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(15),
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
                          color: isSelected
                              ? Colors.green.shade200
                              : Colors.blueGrey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? Colors.green.shade700
                                : Colors.transparent,
                            width: isSelected ? 3.0 : 0.0,
                          ),
                        ),
                        child: Text(
                          controller.items[actualIndex],
                          style: TextStyle(
                            fontSize: isSelected ? 24 : 18,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.green.shade900
                                : Colors.black87,
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
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (controller.selectedIndex.value != null &&
              controller.selectedIndex.value != -1)
            Text(
              '¡El ganador es: ${controller.items[controller.selectedIndex.value!]}!',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
        ],
      ),
    );
  }
}
*/
