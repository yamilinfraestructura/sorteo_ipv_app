import 'package:flutter/material.dart';
import 'package:sorteo_ipv_app/src/presentation/screens/importar_participantes_screen/widgets/importar_participantes_widget.dart';

class ImportarParticipantesScreen extends StatelessWidget {
  const ImportarParticipantesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importar Participantes'),
        backgroundColor: Colors.pink,
      ),
      body: Center(child: ImportarParticipantesWidget()),
    );
  }
}
