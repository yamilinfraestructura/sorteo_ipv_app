// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
//Importación de Archivos
import 'components/component.dart';
import 'widgets/widget.dart';
import 'package:sorteo_ipv_app/src/presentation/screens/home_screen/widgets/tripleslot_machine_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _hightScreen = MediaQuery.of(context).size.height;
    final _widthScreen = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fortuna Prueba'),
        backgroundColor: Colors.pink[400],
      ),
      body: Container(
        height: _hightScreen,
        width: _widthScreen,
        color: Colors.orange[100],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [TripleSlotMachineWidget()],
        ),
      ),
      endDrawer: DrawerComponent(),
    );
  }
}
