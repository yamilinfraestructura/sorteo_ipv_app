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
              child: FortuneWheel(
                selected: controller.selectedIndex.value,
                items: controller.participantes.map((participante) {
                  return FortuneItem(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        participante.nombre,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    style: FortuneItemStyle(
                      color: _getRandomColor(controller.participantes.indexOf(participante)),
                      borderColor: Colors.white,
                      borderWidth: 2,
                    ),
                  );
                }).toList(),
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
