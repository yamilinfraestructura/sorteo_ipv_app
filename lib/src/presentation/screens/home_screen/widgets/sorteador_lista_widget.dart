import 'dart:async';

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
    ];

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      width: widget._widthScreen * 0.5,
      child: GestureDetector(
        onTap: () {
          setState(() {
            selected.add(Fortune.randomInt(0, items.length));
          });
        },
        child: Column(
          children: [
            Expanded(
              child: FortuneWheel(
                selected: selected.stream,
                items: [for (var it in items) FortuneItem(child: Text(it))],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
