import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:get/get.dart';

class SorteadorController extends GetxController {
  late ScrollController scrollController;
  late List<String> items;
  final int listMultiplicationFactor = 10000;
  final double itemHeight;
  final int visibleItems;
  final Random _random = Random();

  final RxnInt selectedIndex = RxnInt();
  final RxBool isScrolling = false.obs;

  double _initialScrollOffset = 0;

  SorteadorController({
    required this.items,
    this.itemHeight = 60.0,
    this.visibleItems = 5,
  });

  @override
  void onInit() {
    super.onInit();

    scrollController = ScrollController();

    // Calcular el offset inicial pero NO hacer jumpTo aquí aún
    _setRandomInitialOffset();
  }

  // Este método deberías llamarlo en el widget cuando el ListView ya esté construido
  void jumpToInitialOffset() {
    if (scrollController.hasClients) {
      scrollController.jumpTo(_initialScrollOffset);
    }
  }

  void _setRandomInitialOffset() {
    if (items.isEmpty) {
      _initialScrollOffset = 0;
      return;
    }
    final int randomStart = _random.nextInt(
      items.length * listMultiplicationFactor ~/ 2,
    );
    _initialScrollOffset = randomStart * itemHeight;
  }

  // Nuevo método para actualizar items dinámicamente
  void actualizarItems(List<String> nuevosItems) {
    // Validar que no haya elementos duplicados
    final itemsUnicos = nuevosItems.toSet().toList();

    if (itemsUnicos.length != nuevosItems.length) {
      print(
        'Advertencia: Se encontraron elementos duplicados en la lista. Se han removido.',
      );
    }

    items = itemsUnicos;
    selectedIndex.value = null;
    _setRandomInitialOffset();

    // Si el scroll controller ya tiene clients, actualizar la posición
    if (scrollController.hasClients) {
      scrollController.jumpTo(_initialScrollOffset);
    }
  }

  Future<void> startAutomaticDraw() async {
    if (isScrolling.value || !scrollController.hasClients) return;

    selectedIndex.value = null;
    isScrolling.value = true;

    _setRandomInitialOffset();
    scrollController.jumpTo(_initialScrollOffset);

    const int minRotations = 25;
    final int baseIndex = (_initialScrollOffset / itemHeight).floor();
    final int randomOffsetIndex =
        baseIndex +
        (minRotations * items.length) +
        _random.nextInt(items.length);

    final double roughTargetOffset = randomOffsetIndex * itemHeight;

    await scrollController.animateTo(
      roughTargetOffset,
      duration: const Duration(seconds: 4),
      curve: Curves.easeOutExpo,
    );

    await Future.delayed(const Duration(milliseconds: 300));

    final double currentOffset = scrollController.offset;
    final double centerOfViewport =
        currentOffset + (itemHeight * visibleItems / 2);

    final double indexWithOffset =
        (centerOfViewport - (itemHeight / 2)) / itemHeight;
    final int closestIndex = indexWithOffset.round();
    final int winningIndex = closestIndex % items.length;

    final double finalOffset =
        (closestIndex * itemHeight) -
        ((itemHeight * visibleItems / 2) - (itemHeight / 2));

    await scrollController.animateTo(
      finalOffset,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
    );

    await Future.delayed(const Duration(milliseconds: 100));

    selectedIndex.value = winningIndex;
    isScrolling.value = false;
  }

  void stopManualScroll() async {
    if (isScrolling.value || !scrollController.hasClients) return;

    isScrolling.value = true;
    selectedIndex.value = null;

    final double currentOffset = scrollController.offset;
    final double centerOfViewport =
        currentOffset + (itemHeight * visibleItems / 2);

    final double indexWithOffset =
        (centerOfViewport - (itemHeight / 2)) / itemHeight;
    final int closestIndex = indexWithOffset.round();
    final int winningIndex = closestIndex % items.length;

    final double targetOffset =
        (closestIndex * itemHeight) -
        ((itemHeight * visibleItems / 2) - (itemHeight / 2));

    await scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 1200),
      curve: Curves.decelerate,
    );

    await Future.delayed(const Duration(milliseconds: 50));

    selectedIndex.value = winningIndex;
    isScrolling.value = false;
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
