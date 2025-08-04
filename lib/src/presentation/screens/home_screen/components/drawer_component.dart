import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:get/get.dart';

class DrawerComponent extends StatelessWidget {
  const DrawerComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
              Get.toNamed('/importar-participantes');
            },
          ),
          ListTile(
            leading: const Icon(Icons.import_export),
            title: const Text('Cargar Participantes'),
            onTap: () {
              // Acción al pulsar el elemento
              Get.toNamed('/cargar-manzanas');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Cargar Posiciones'),
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
    );
  }
}
