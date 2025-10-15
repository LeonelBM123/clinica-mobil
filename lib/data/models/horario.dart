class TipoAtencion {
  final int id;
  final String nombre;
  final String? descripcion;
  final bool estado;

  TipoAtencion({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.estado,
  });

  factory TipoAtencion.fromJson(Map<String, dynamic> json) {
    return TipoAtencion(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'estado': estado,
    };
  }

  @override
  String toString() => nombre;
}

class BloqueHorario {
  final int id;
  final String diaSemana;
  final DateTime horaInicio;
  final DateTime horaFin;
  final bool estado;
  final int duracionCitaMinutos;
  final int maxCitasPorBloque;
  final DateTime fechaCreacion;
  final DateTime fechaModificacion;
  final int medicoId;
  final TipoAtencion? tipoAtencion;

  BloqueHorario({
    required this.id,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
    required this.estado,
    required this.duracionCitaMinutos,
    required this.maxCitasPorBloque,
    required this.fechaCreacion,
    required this.fechaModificacion,
    required this.medicoId,
    this.tipoAtencion,
  });

  factory BloqueHorario.fromJson(Map<String, dynamic> json) {
    try {
      return BloqueHorario(
        id: json['id'] ?? 0,
        diaSemana: json['dia_semana'] ?? '',
        horaInicio: json['hora_inicio'] != null 
            ? DateTime.parse('2000-01-01 ${json['hora_inicio']}')
            : DateTime(2000, 1, 1, 8, 0), // Default 8:00 AM
        horaFin: json['hora_fin'] != null 
            ? DateTime.parse('2000-01-01 ${json['hora_fin']}')
            : DateTime(2000, 1, 1, 17, 0), // Default 5:00 PM
        estado: json['estado'] ?? true,
        duracionCitaMinutos: json['duracion_cita_minutos'] ?? 30,
        maxCitasPorBloque: json['max_citas_por_bloque'] ?? 1,
        fechaCreacion: json['fecha_creacion'] != null 
            ? DateTime.parse(json['fecha_creacion'])
            : DateTime.now(),
        fechaModificacion: json['fecha_modificacion'] != null 
            ? DateTime.parse(json['fecha_modificacion'])
            : DateTime.now(),
        medicoId: json['medico'] ?? 0,
        tipoAtencion: json['tipo_atencion'] != null 
            ? (json['tipo_atencion'] is Map<String, dynamic> 
                ? TipoAtencion.fromJson(json['tipo_atencion'])
                : TipoAtencion(
                    id: json['tipo_atencion'] as int,
                    nombre: json['tipo_atencion_nombre'] ?? 'Tipo de Atención',
                    estado: true,
                  ))
            : null,
      );
    } catch (e) {
      print('❌ Error parsing BloqueHorario JSON: $e');
      print('❌ JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dia_semana': diaSemana,
      'hora_inicio': '${horaInicio.hour.toString().padLeft(2, '0')}:${horaInicio.minute.toString().padLeft(2, '0')}',
      'hora_fin': '${horaFin.hour.toString().padLeft(2, '0')}:${horaFin.minute.toString().padLeft(2, '0')}',
      'estado': estado,
      'duracion_cita_minutos': duracionCitaMinutos,
      'max_citas_por_bloque': maxCitasPorBloque,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_modificacion': fechaModificacion.toIso8601String(),
      'medico': medicoId,
      'tipo_atencion': tipoAtencion?.id,
    };
  }

  String get diaSemanaDisplay {
    switch (diaSemana) {
      case 'LUNES':
        return 'Lunes';
      case 'MARTES':
        return 'Martes';
      case 'MIERCOLES':
        return 'Miércoles';
      case 'JUEVES':
        return 'Jueves';
      case 'VIERNES':
        return 'Viernes';
      case 'SABADO':
        return 'Sábado';
      case 'DOMINGO':
        return 'Domingo';
      default:
        return diaSemana;
    }
  }

  String get horarioDisplay =>
      '${horaInicio.hour.toString().padLeft(2, '0')}:${horaInicio.minute.toString().padLeft(2, '0')} - ${horaFin.hour.toString().padLeft(2, '0')}:${horaFin.minute.toString().padLeft(2, '0')}';

  @override
  String toString() =>
      '$diaSemanaDisplay $horarioDisplay';
}