import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';

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
    final items = <String>[
      'Grogu',
      'Mace Windu',
      'Obi-Wan Kenobi',
      'Han Solo',
      'Luke Skywalker',
      'Darth Vader',
      'Yoda',
      'Ahsoka Tano',
      'Rolando Molina',
    ];

    return Center(
      // Centramos el widget en la pantalla
      child: SizedBox(
        height:
            MediaQuery.of(context).size.height *
            0.8, // Puedes ajustar la altura
        width: widget._widthScreen * 0.8, // Puedes ajustar el ancho
        child: CustomVerticalLottery(
          items: items,
          itemHeight: 70.0, // Puedes ajustar la altura de cada elemento
          visibleItems: 5, // Cantidad de elementos visibles
        ),
      ),
    );

    /*SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      width: widget._widthScreen * 0.5,
      child: GestureDetector(
        onTap: () {
          selected.add(Fortune.randomInt(0, items.length));
        },
        child: Column(
          children: [
            Expanded(
              child: FortuneBar(
                selected: selected.stream,
                items: [for (var it in items) FortuneItem(child: Text(it))],
              ),
            ),
          ],
        ),
      ),
    );*/
  }
}

class CustomVerticalLottery extends StatefulWidget {
  const CustomVerticalLottery({
    super.key,
    required this.items,
    this.itemHeight = 60.0,
    this.visibleItems = 5,
  });

  final List<String> items;
  final double itemHeight;
  final int visibleItems;

  @override
  State<CustomVerticalLottery> createState() => _CustomVerticalLotteryState();
}

class _CustomVerticalLotteryState extends State<CustomVerticalLottery> {
  final ScrollController _scrollController = ScrollController();
  final Random _random = Random();
  int? _selectedIndex;
  bool _isScrolling = false;

  static const int _listMultiplicationFactor = 10000;
  late double _initialScrollOffset;

  @override
  void initState() {
    super.initState();
    _setRandomInitialOffset();
  }

  void _setRandomInitialOffset() {
    final int randomStartingItem = _random.nextInt(
      widget.items.length * _listMultiplicationFactor ~/ 2,
    );
    _initialScrollOffset = randomStartingItem * widget.itemHeight;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _startLottery() async {
    if (_isScrolling) return;

    setState(() {
      _selectedIndex = null;
      _isScrolling = true;
    });

    _setRandomInitialOffset();
    _scrollController.jumpTo(_initialScrollOffset);

    // Calculamos un índice aleatorio alto para dar varias vueltas
    const int minRotations = 25;
    final int baseIndex = (_initialScrollOffset / widget.itemHeight).floor();
    final int randomOffsetIndex =
        baseIndex +
        (minRotations * widget.items.length) +
        _random.nextInt(widget.items.length);

    final double roughTargetOffset = (randomOffsetIndex * widget.itemHeight);

    await _scrollController.animateTo(
      roughTargetOffset,
      duration: const Duration(seconds: 4),
      curve: Curves.easeOutExpo,
    );

    // Esperamos un poco para que la animación se asiente
    await Future.delayed(const Duration(milliseconds: 300));

    // Obtenemos el índice del ítem que quedó centrado
    final double currentOffset = _scrollController.offset;
    final double centerOfViewport =
        currentOffset + (widget.itemHeight * widget.visibleItems / 2);

    final double indexWithOffset =
        (centerOfViewport - (widget.itemHeight / 2)) / widget.itemHeight;

    final int closestIndex = indexWithOffset.round();
    final int winningIndex = closestIndex % widget.items.length;

    final double finalOffset =
        (closestIndex * widget.itemHeight) -
        ((widget.itemHeight * widget.visibleItems / 2) -
            (widget.itemHeight / 2));

    // Corrección final suave al centro perfecto
    await _scrollController.animateTo(
      finalOffset,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
    );

    await Future.delayed(const Duration(milliseconds: 100));

    setState(() {
      _selectedIndex = winningIndex;
      _isScrolling = false;
    });
  }

  void _stopLotteryOnPanEnd() async {
    if (_isScrolling) return;

    setState(() {
      _isScrolling = true;
      _selectedIndex = null;
    });

    final double currentOffset = _scrollController.offset;
    final double visibleHeight = widget.itemHeight * widget.visibleItems;
    final double centerOfViewport = currentOffset + (visibleHeight / 2);

    // Preciso: posición del ítem cuya parte superior quedaría centrada
    final double indexWithOffset =
        (centerOfViewport - (widget.itemHeight / 2)) / widget.itemHeight;
    final int closestIndex = indexWithOffset.round();
    final int winningIndex = closestIndex % widget.items.length;

    final double targetOffset =
        (closestIndex * widget.itemHeight) -
        ((visibleHeight / 2) - (widget.itemHeight / 2));

    await _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 1200),
      curve: Curves.decelerate,
    );

    await Future.delayed(const Duration(milliseconds: 50));

    setState(() {
      _selectedIndex = winningIndex;
      _isScrolling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _startLottery,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            textStyle: const TextStyle(fontSize: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('¡Sortear! (Automático)'),
        ),
        const SizedBox(height: 20),
        Container(
          height: widget.itemHeight * widget.visibleItems,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollEndNotification && !_isScrolling) {
                    Future.delayed(const Duration(milliseconds: 800), () {
                      if (!_isScrolling)
                        _stopLotteryOnPanEnd(); // da tiempo a la inercia real
                    });
                  }
                  return false;
                },

                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: widget.items.length * _listMultiplicationFactor,
                  itemExtent: widget.itemHeight,
                  physics: const BouncingScrollPhysics(), // ← efecto natural
                  itemBuilder: (context, index) {
                    final actualIndex = index % widget.items.length;
                    final isSelected = _selectedIndex == actualIndex;

                    return Container(
                      height: widget.itemHeight,
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
                        widget.items[actualIndex],
                        style: TextStyle(
                          fontSize: isSelected ? 24 : 18,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? Colors.green.shade900
                              : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
              Center(
                child: Container(
                  height: widget.itemHeight,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
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
        if (_selectedIndex != null)
          Text(
            '¡El ganador es: ${widget.items[_selectedIndex!]}!',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}
