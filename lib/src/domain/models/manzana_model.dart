class ManzanaModel {
  final String id;
  final String manzana;
  final String posicion;
  final String nc;
  final String geoposicion;
  final bool disponible; // ← Nuevo campo

  ManzanaModel({
    required this.id,
    required this.manzana,
    required this.posicion,
    required this.nc,
    required this.geoposicion,
    required this.disponible,
  });

  factory ManzanaModel.fromMap(String id, Map<String, dynamic> data) {
    return ManzanaModel(
      id: id,
      manzana: data['manzana'] ?? '',
      posicion: data['posicion'] ?? '',
      nc: data['NC'] ?? '',
      geoposicion: data['geoposicion'] ?? '',
      disponible: data['disponible'] ?? true, // ← por defecto true si no existe
    );
  }
}
