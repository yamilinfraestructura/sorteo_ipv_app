// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';

class ParticipanteModel {
  final String dni;
  final String nombre;
  final String apellido;
  final String sexo;
  final String fNac;
  final String tel;
  final String barrio;
  final String departamento;
  final String localidad;
  final String domicilio;
  final String nroInscripcion;
  final String nroParaSorteo;
  final String ordenSorteado;
  final String expediente;
  final String ficha;
  final String preferencialFicha;
  final String descripcion1;
  final String descripcion2;
  final String circuitoipvTxt;
  final String circuitoipvNota;
  final String estudios;
  final String ingresoMensual;
  final String grupreferencial;
  final String estado;
  final String estadoTxt;
  final String fAlta;
  final String fBaja;
  final String fBaja2;
  final String fFall;
  final String fmodif;
  final bool haSidoSorteado;
  final String idSorteo;
  final DateTime? timestampInscripcion;
  final String reemp;
  final String cantOcupantes;

  ParticipanteModel({
    required this.dni,
    required this.nombre,
    required this.apellido,
    required this.sexo,
    required this.fNac,
    required this.tel,
    required this.barrio,
    required this.departamento,
    required this.localidad,
    required this.domicilio,
    required this.nroInscripcion,
    required this.nroParaSorteo,
    required this.ordenSorteado,
    required this.expediente,
    required this.ficha,
    required this.preferencialFicha,
    required this.descripcion1,
    required this.descripcion2,
    required this.circuitoipvTxt,
    required this.circuitoipvNota,
    required this.estudios,
    required this.ingresoMensual,
    required this.grupreferencial,
    required this.estado,
    required this.estadoTxt,
    required this.fAlta,
    required this.fBaja,
    required this.fBaja2,
    required this.fFall,
    required this.fmodif,
    required this.haSidoSorteado,
    required this.idSorteo,
    required this.timestampInscripcion,
    required this.reemp,
    required this.cantOcupantes,
  });

  factory ParticipanteModel.fromMap(Map<String, dynamic> data) {
    return ParticipanteModel(
      dni: data['dni'] ?? '',
      nombre: data['nombre'] ?? '',
      apellido: data['apellido'] ?? '',
      sexo: data['sexo'] ?? '',
      fNac: data['f_nac'] ?? '',
      tel: data['tel'] ?? '',
      barrio: data['barrio'] ?? '',
      departamento: data['departamento'] ?? '',
      localidad: data['localidad'] ?? '',
      domicilio: data['domicilio'] ?? '',
      nroInscripcion: data['nro_inscripcion'] ?? '',
      nroParaSorteo: data['nro_para_sorteo'] ?? '',
      ordenSorteado: data['orden_sorteado'] ?? '',
      expediente: data['expediente'] ?? '',
      ficha: data['ficha'] ?? '',
      preferencialFicha: data['preferencial_ficha'] ?? '',
      descripcion1: data['descripcion1'] ?? '',
      descripcion2: data['descripcion2'] ?? '',
      circuitoipvTxt: data['circuitoipv_txt'] ?? '',
      circuitoipvNota: data['circuitoipv_nota'] ?? '',
      estudios: data['estudios'] ?? '',
      ingresoMensual: data['ingreso_mensual'] ?? '',
      grupreferencial: data['grupreferencial'] ?? '',
      estado: data['estado'] ?? '',
      estadoTxt: data['estado_txt'] ?? '',
      fAlta: data['f_alta'] ?? '',
      fBaja: data['f_baja'] ?? '',
      fBaja2: data['f_baja2'] ?? '',
      fFall: data['f_fall'] ?? '',
      fmodif: data['fmodif'] ?? '',
      haSidoSorteado: data['haSidoSorteado'] ?? false,
      idSorteo: data['idSorteo'] ?? '',
      timestampInscripcion: data['timestampInscripcion'] != null
          ? (data['timestampInscripcion'] as Timestamp).toDate()
          : null,
      reemp: data['reemp'] ?? '',
      cantOcupantes: data['cant_ocupantes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dni': dni,
      'nombre': nombre,
      'apellido': apellido,
      'sexo': sexo,
      'f_nac': fNac,
      'tel': tel,
      'barrio': barrio,
      'departamento': departamento,
      'localidad': localidad,
      'domicilio': domicilio,
      'nro_inscripcion': nroInscripcion,
      'nro_para_sorteo': nroParaSorteo,
      'orden_sorteado': ordenSorteado,
      'expediente': expediente,
      'ficha': ficha,
      'preferencial_ficha': preferencialFicha,
      'descripcion1': descripcion1,
      'descripcion2': descripcion2,
      'circuitoipv_txt': circuitoipvTxt,
      'circuitoipv_nota': circuitoipvNota,
      'estudios': estudios,
      'ingreso_mensual': ingresoMensual,
      'grupreferencial': grupreferencial,
      'estado': estado,
      'estado_txt': estadoTxt,
      'f_alta': fAlta,
      'f_baja': fBaja,
      'f_baja2': fBaja2,
      'f_fall': fFall,
      'fmodif': fmodif,
      'haSidoSorteado': haSidoSorteado,
      'idSorteo': idSorteo,
      'timestampInscripcion': timestampInscripcion,
      'reemp': reemp,
      'cant_ocupantes': cantOcupantes,
    };
  }

  String get nombreCompleto => '$apellido $nombre';
}
