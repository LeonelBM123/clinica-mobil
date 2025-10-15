class CitaMedica {
  final int? id;
  final String fecha;
  final String horaInicio;
  final String horaFin;
  final String estadoCita;
  final String? notas;
  final String? motivoCancelacion;
  final int? calificacion;
  final String? comentarioCalificacion;
  final int pacienteId;
  final String? pacienteNombre;
  final int bloqueHorarioId;
  final String? medicoNombre;
  final int? grupo;

  CitaMedica({
    this.id,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.estadoCita,
    this.notas,
    this.motivoCancelacion,
    this.calificacion,
    this.comentarioCalificacion,
    required this.pacienteId,
    this.pacienteNombre,
    required this.bloqueHorarioId,
    this.medicoNombre,
    this.grupo,
  });

  factory CitaMedica.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 [CitaMedica] Parsing JSON: $json');
      
      // Hacer casts explícitos y seguros para todos los campos
      final id = json['id'] as int?;
      print('🔍 [CitaMedica] id: $id');
      
      final fecha = (json['fecha'] as String?) ?? '';
      print('🔍 [CitaMedica] fecha: $fecha');
      
      // Manejar formato de hora más flexible (puede venir como "09:50" o "09:50:00")
      final horaInicioRaw = (json['hora_inicio'] as String?) ?? '';
      final horaInicio = horaInicioRaw.length > 5 ? horaInicioRaw.substring(0, 5) : horaInicioRaw;
      print('🔍 [CitaMedica] horaInicio: $horaInicioRaw -> $horaInicio');
      
      final horaFinRaw = (json['hora_fin'] as String?) ?? '';
      final horaFin = horaFinRaw.length > 5 ? horaFinRaw.substring(0, 5) : horaFinRaw;
      print('🔍 [CitaMedica] horaFin: $horaFinRaw -> $horaFin');
      
      final estadoCita = (json['estado_cita'] as String?) ?? 'PENDIENTE';
      print('🔍 [CitaMedica] estadoCita: $estadoCita');
      
      final notas = json['notas'] as String?;
      print('🔍 [CitaMedica] notas: $notas');
      
      final motivoCancelacion = json['motivo_cancelacion'] as String?;
      print('🔍 [CitaMedica] motivoCancelacion: $motivoCancelacion');
      
      final calificacion = json['calificacion'] as int?;
      print('🔍 [CitaMedica] calificacion: $calificacion');
      
      final comentarioCalificacion = json['comentario_calificacion'] as String?;
      print('🔍 [CitaMedica] comentarioCalificacion: $comentarioCalificacion');
      
      final pacienteId = (json['paciente'] as int?) ?? 0;
      print('🔍 [CitaMedica] pacienteId: $pacienteId');
      
      final pacienteNombre = json['paciente_nombre'] as String?;
      final pacienteNombreLimpio = pacienteNombre?.replaceAll('\n', ' ').trim();
      print('🔍 [CitaMedica] pacienteNombre: "$pacienteNombre" -> "$pacienteNombreLimpio"');
      
      final bloqueHorarioId = (json['bloque_horario'] as int?) ?? 0;
      print('🔍 [CitaMedica] bloqueHorarioId: $bloqueHorarioId');
      
      final medicoNombre = json['medico_nombre'] as String?;
      final medicoNombreLimpio = medicoNombre?.replaceAll('\n', ' ').trim();
      print('🔍 [CitaMedica] medicoNombre: "$medicoNombre" -> "$medicoNombreLimpio"');
      
      final grupo = json['grupo'] as int?;
      print('🔍 [CitaMedica] grupo: $grupo');
      
      print('🔍 [CitaMedica] Campos parseados exitosamente');
      
      return CitaMedica(
        id: id,
        fecha: fecha,
        horaInicio: horaInicio,
        horaFin: horaFin,
        estadoCita: estadoCita,
        notas: notas,
        motivoCancelacion: motivoCancelacion,
        calificacion: calificacion,
        comentarioCalificacion: comentarioCalificacion,
        pacienteId: pacienteId,
        pacienteNombre: pacienteNombreLimpio,
        bloqueHorarioId: bloqueHorarioId,
        medicoNombre: medicoNombreLimpio,
        grupo: grupo,
      );
    } catch (e, stackTrace) {
      print('❌ Error parsing CitaMedica JSON: $e');
      print('❌ Stack trace: $stackTrace');
      print('❌ JSON data: $json');
      print('❌ JSON data types:');
      json.forEach((key, value) {
        print('   $key: ${value.runtimeType} = $value');
      });
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha': fecha,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'estado_cita': estadoCita,
      'notas': notas,
      'motivo_cancelacion': motivoCancelacion,
      'calificacion': calificacion,
      'comentario_calificacion': comentarioCalificacion,
      'paciente': pacienteId,
      'bloque_horario': bloqueHorarioId,
      'grupo': grupo,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'fecha': fecha,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'notas': notas ?? '',
      'bloque_horario': bloqueHorarioId,
    };
  }

  // Estado de la cita como texto
  String get estadoTexto {
    switch (estadoCita) {
      case 'PENDIENTE':
        return 'Pendiente';
      case 'CONFIRMADA':
        return 'Confirmada';
      case 'COMPLETADA':
        return 'Completada';
      case 'CANCELADA':
        return 'Cancelada';
      default:
        return estadoCita;
    }
  }

  // Estado como booleano para compatibilidad (activa si no está cancelada)
  bool get estado {
    return estadoCita != 'CANCELADA';
  }
  
  // Fecha y hora formateada para mostrar
  String get fechaHoraFormateada => '$fecha $horaInicio - $horaFin';
}