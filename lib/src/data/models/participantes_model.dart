
class ParticipanteModel {
  final String? id;
  final String nroParaSorteo;
  final String ordenSorteado;
  final String nroInscripcion;
  final String dni;
  final String apellido;
  final String nombre;
  final String sexo;
  final String fNac;
  final String ingresoMensual;
  final String estudios;
  final String fFall;
  final String fBaja;
  final String departamento;
  final String localidad;
  final String barrio;
  final String domicilio;
  final String tel;
  final String cantOcupantes;
  final String descripcion1;
  final String descripcion2;
  final String grupReferencial;
  final String preferencialFicha;
  final String ficha;
  final String fAlta;
  final String fmodif;
  final String fBaja2;
  final String expediente;
  final String reemp;
  final String estadoTxt;
  final String circuitoipvTxt;
  final String circuitoipvNota;
  final String idSorteo;

  ParticipanteModel({
    this.id,
    required this.nroParaSorteo,
    required this.ordenSorteado,
    required this.nroInscripcion,
    required this.dni,
    required this.apellido,
    required this.nombre,
    required this.sexo,
    required this.fNac,
    required this.ingresoMensual,
    required this.estudios,
    required this.fFall,
    required this.fBaja,
    required this.departamento,
    required this.localidad,
    required this.barrio,
    required this.domicilio,
    required this.tel,
    required this.cantOcupantes,
    required this.descripcion1,
    required this.descripcion2,
    required this.grupReferencial,
    required this.preferencialFicha,
    required this.ficha,
    required this.fAlta,
    required this.fmodif,
    required this.fBaja2,
    required this.expediente,
    required this.reemp,
    required this.estadoTxt,
    required this.circuitoipvTxt,
    required this.circuitoipvNota,
    required this.idSorteo,
  });

  factory ParticipanteModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ParticipanteModel(
      id: id,
      nroParaSorteo: map['nro_para_sorteo'] ?? '',
      ordenSorteado: map['orden_sorteado'] ?? '',
      nroInscripcion: map['nro_inscripcion'] ?? '',
      dni: map['dni'] ?? '',
      apellido: map['apellido'] ?? '',
      nombre: map['nombre'] ?? '',
      sexo: map['sexo'] ?? '',
      fNac: map['f_nac'] ?? '',
      ingresoMensual: map['ingreso_mensual'] ?? '',
      estudios: map['estudios'] ?? '',
      fFall: map['f_fall'] ?? '',
      fBaja: map['f_baja'] ?? '',
      departamento: map['departamento'] ?? '',
      localidad: map['localidad'] ?? '',
      barrio: map['barrio'] ?? '',
      domicilio: map['domicilio'] ?? '',
      tel: map['tel'] ?? '',
      cantOcupantes: map['cant_ocupantes'] ?? '',
      descripcion1: map['descripcion1'] ?? '',
      descripcion2: map['descripcion2'] ?? '',
      grupReferencial: map['grupreferencial'] ?? '',
      preferencialFicha: map['preferencial_ficha'] ?? '',
      ficha: map['ficha'] ?? '',
      fAlta: map['f_alta'] ?? '',
      fmodif: map['fmodif'] ?? '',
      fBaja2: map['f_baja2'] ?? '',
      expediente: map['expediente'] ?? '',
      reemp: map['reemp'] ?? '',
      estadoTxt: map['estado_txt'] ?? '',
      circuitoipvTxt: map['circuitoipv_txt'] ?? '',
      circuitoipvNota: map['circuitoipv_nota'] ?? '',
      idSorteo: map['idSorteo'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nro_para_sorteo': nroParaSorteo,
      'orden_sorteado': ordenSorteado,
      'nro_inscripcion': nroInscripcion,
      'dni': dni,
      'apellido': apellido,
      'nombre': nombre,
      'sexo': sexo,
      'f_nac': fNac,
      'ingreso_mensual': ingresoMensual,
      'estudios': estudios,
      'f_fall': fFall,
      'f_baja': fBaja,
      'departamento': departamento,
      'localidad': localidad,
      'barrio': barrio,
      'domicilio': domicilio,
      'tel': tel,
      'cant_ocupantes': cantOcupantes,
      'descripcion1': descripcion1,
      'descripcion2': descripcion2,
      'grupreferencial': grupReferencial,
      'preferencial_ficha': preferencialFicha,
      'ficha': ficha,
      'f_alta': fAlta,
      'fmodif': fmodif,
      'f_baja2': fBaja2,
      'expediente': expediente,
      'reemp': reemp,
      'estado_txt': estadoTxt,
      'circuitoipv_txt': circuitoipvTxt,
      'circuitoipv_nota': circuitoipvNota,
      'idSorteo': idSorteo,
    };
  }

  String get nombreCompleto => '$apellido, $nombre';
}
