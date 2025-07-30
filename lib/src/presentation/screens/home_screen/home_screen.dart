// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';

import 'widgets/widget.dart';

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
          children: [SorteadorListaWidget(widthScreen: _widthScreen)],
        ),
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: const Text(
                'Sorteador IPV',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.import_export),
              title: const Text('Importar Participantes'),
              onTap: () {
                // Acción al pulsar el elemento
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
              onTap: () {
                // Acción al pulsar el elemento
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Acerca de'),
              onTap: () {
                // Acción al pulsar el elemento
              },
            ),
          ],
        ),
      ),
    );
  }
}
