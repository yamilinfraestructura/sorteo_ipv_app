import 'package:flutter/material.dart';
import 'package:sorteo_ipv_app/src/presentation/screens/cargar_manzanas_screen/widgets/importar_manzanas_widget.dart';

class CargarManzanasScreen extends StatelessWidget {
  const CargarManzanasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cargar Manzanas y Posiciones'),
        backgroundColor: Colors.pink,
      ),
      body: Center(child: ImportarManzanasWidget()),
    );
  }
}
