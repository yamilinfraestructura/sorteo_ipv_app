// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:sorteo_ipv_app/src/presentation/screens/home_screen/widgets/widget.dart';
import 'components/component.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _heightScreen = MediaQuery.of(context).size.height;
    final _widthScreen = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sorteador Triple'),
        backgroundColor: Colors.amberAccent,
        elevation: 4,
      ),
      body: Container(
        width: _widthScreen,
        height: _heightScreen,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade100, Colors.amber.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(child: TripleSlotMachineWidget()),
      ),
      endDrawer: DrawerComponent(),
    );
  }
}
