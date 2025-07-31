import 'package:flutter/material.dart';

class ImportarParticipantesScreen extends StatelessWidget {
  const ImportarParticipantesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importar Participantes'),
        backgroundColor: Colors.pink,
      ),
      body: const Center(child: Text('Aquí se importarán los participantes.')),
    );
  }
}
