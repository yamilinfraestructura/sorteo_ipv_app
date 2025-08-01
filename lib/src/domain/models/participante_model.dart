class ParticipanteModel {
  final String dni;
  final String apellido;
  final String nombre;
  final String? nroParaSorteo;
  final String? ordenSorteado;
  final String? nroInscripcion;
  final String? sexo;
  final String? departamento;
  final String? localidad;
  final String? barrio;
  final String? domicilio;
  final String? estado;

  ParticipanteModel({
    required this.dni,
    required this.apellido,
    required this.nombre,
    this.nroParaSorteo,
    this.ordenSorteado,
    this.nroInscripcion,
    this.sexo,
    this.departamento,
    this.localidad,
    this.barrio,
    this.domicilio,
    this.estado,
  });

  factory ParticipanteModel.fromMap(Map<String, dynamic> map) {
    return ParticipanteModel(
      dni: map['dni'] ?? '',
      apellido: map['apellido'] ?? '',
      nombre: map['nombre'] ?? '',
      nroParaSorteo: map['nro_para_sorteo'],
      ordenSorteado: map['orden_sorteado'],
      nroInscripcion: map['nro_inscripcion'],
      sexo: map['sexo'],
      departamento: map['departamento'],
      localidad: map['localidad'],
      barrio: map['barrio'],
      domicilio: map['domicilio'],
      estado: map['estado'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dni': dni,
      'apellido': apellido,
      'nombre': nombre,
      'nro_para_sorteo': nroParaSorteo,
      'orden_sorteado': ordenSorteado,
      'nro_inscripcion': nroInscripcion,
      'sexo': sexo,
      'departamento': departamento,
      'localidad': localidad,
      'barrio': barrio,
      'domicilio': domicilio,
      'estado': estado,
    };
  }
}
