class CitaMedica {
  final int? id;
  final String fecha;
  final String horaInicio;
  final String horaFin;
  final bool estado;
  final String? notas;
  final String? motivoCancelacion;
  final DateTime fechaCreacion;
  final DateTime? fechaModificacion;
  final int pacienteId;
  final int bloqueHorarioId;
  
  // Información adicional para mostrar en la UI
  final String? nombreMedico;
  final String? especialidadMedico;
  final String? diaSemana;

  CitaMedica({
    this.id,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.estado,
    this.notas,
    this.motivoCancelacion,
    required this.fechaCreacion,
    this.fechaModificacion,
    required this.pacienteId,
    required this.bloqueHorarioId,
    this.nombreMedico,
    this.especialidadMedico,
    this.diaSemana,
  });

  factory CitaMedica.fromJson(Map<String, dynamic> json) {
    return CitaMedica(
      id: json['id'],
      fecha: json['fecha'],
      horaInicio: json['hora_inicio'],
      horaFin: json['hora_fin'],
      estado: json['estado'] ?? true,
      notas: json['notas'],
      motivoCancelacion: json['motivo_cancelacion'],
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
      fechaModificacion: json['fecha_modificacion'] != null 
          ? DateTime.parse(json['fecha_modificacion']) 
          : null,
      pacienteId: json['paciente'],
      bloqueHorarioId: json['bloque_horario'],
      nombreMedico: json['nombre_medico'],
      especialidadMedico: json['especialidad_medico'],
      diaSemana: json['dia_semana'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha': fecha,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'estado': estado,
      'notas': notas,
      'motivo_cancelacion': motivoCancelacion,
      'paciente': pacienteId,
      'bloque_horario': bloqueHorarioId,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'fecha': fecha,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'notas': notas ?? '',
      'paciente': pacienteId,
      'bloque_horario': bloqueHorarioId,
    };
  }

  // Estado de la cita como texto
  String get estadoTexto => estado ? 'Activa' : 'Cancelada';
  
  // Fecha y hora formateada para mostrar
  String get fechaHoraFormateada => '$fecha $horaInicio - $horaFin';
}