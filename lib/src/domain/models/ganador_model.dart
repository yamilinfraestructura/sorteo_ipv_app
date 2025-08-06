import 'package:cloud_firestore/cloud_firestore.dart';

class GanadorModel {
  final String id;
  final String participanteId;
  final String manzanaId;
  final String nombreCompleto;
  final String manzanaNombre; // Nuevo campo
  final String loteNombre; // Nuevo campo
  final DateTime? fechaSorteo;

  GanadorModel({
    required this.id,
    required this.participanteId,
    required this.manzanaId,
    required this.nombreCompleto,
    required this.manzanaNombre, // Nuevo campo
    required this.loteNombre, // Nuevo campo
    this.fechaSorteo,
  });

  factory GanadorModel.fromMap(String id, Map<String, dynamic> data) {
    return GanadorModel(
      id: id,
      participanteId: data['participanteId'] ?? '',
      manzanaId: data['manzanaId'] ?? '',
      nombreCompleto: data['nombreCompleto'] ?? '',
      manzanaNombre: data['manzanaNombre'] ?? '', // Mapeo del nuevo campo
      loteNombre: data['loteNombre'] ?? '', // Mapeo del nuevo campo
      fechaSorteo: data['fechaSorteo'] != null
          ? (data['fechaSorteo'] as Timestamp).toDate()
          : null,
    );
  }
}
