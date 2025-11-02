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
    final int? medicoId;
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
      this.medicoId,
      this.grupo,
    });

    factory CitaMedica.fromJson(Map<String, dynamic> json) {
      final id = json['id'] as int?;
      final fecha = (json['fecha'] as String?) ?? '';
      final horaInicioRaw = (json['hora_inicio'] as String?) ?? '';
      final horaInicio = horaInicioRaw.length > 5 ? horaInicioRaw.substring(0, 5) : horaInicioRaw;
      final horaFinRaw = (json['hora_fin'] as String?) ?? '';
      final horaFin = horaFinRaw.length > 5 ? horaFinRaw.substring(0, 5) : horaFinRaw;
      final estadoCita = (json['estado_cita'] as String?) ?? 'PENDIENTE';
      final notas = json['notas'] as String?;
      final motivoCancelacion = json['motivo_cancelacion'] as String?;
      final calificacion = json['calificacion'] as int?;
      final comentarioCalificacion = json['comentario_calificacion'] as String?;
      final pacienteId = (json['paciente'] as int?) ?? 0;
      final pacienteNombre = json['paciente_nombre'] as String?;
      final pacienteNombreLimpio = pacienteNombre?.replaceAll('\n', ' ').trim();
      final bloqueHorarioId = (json['bloque_horario'] as int?) ?? 0;
      final medicoNombre = json['medico_nombre'] as String?;
      final medicoNombreLimpio = medicoNombre?.replaceAll('\n', ' ').trim();
      final grupo = json['grupo'] as int?;
      int? medicoId;
      if (json['medico'] != null) {
        if (json['medico'] is int) {
          medicoId = json['medico'] as int?;
        } else if (json['medico'] is String) {
          medicoId = int.tryParse(json['medico']);
        }
      }
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
        medicoId: medicoId,
        grupo: grupo,
      );
    }

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

    bool get estado {
      return estadoCita != 'CANCELADA';
    }

    String get fechaHoraFormateada => '$fecha $horaInicio - $horaFin';
}