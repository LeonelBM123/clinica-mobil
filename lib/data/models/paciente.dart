class Paciente {
  final int id;
  final String numeroHistoriaClinica;
  final String nombre;
  final String apellido;
  final DateTime? fechaNacimiento;
  final String? alergias;
  final String? antecedentesOculares;
  final bool estado;
  final DateTime fechaCreacion;
  final DateTime fechaModificacion;

  // Relación: lista de exámenes
  final List<ExamenOcular> examenes;

  Paciente({
    required this.id,
    required this.numeroHistoriaClinica,
    required this.nombre,
    required this.apellido,
    this.fechaNacimiento,
    this.alergias,
    this.antecedentesOculares,
    required this.estado,
    required this.fechaCreacion,
    required this.fechaModificacion,
    this.examenes = const [],
  });

  factory Paciente.fromJson(Map<String, dynamic> json) {
    return Paciente(
      id: json['id'],
      numeroHistoriaClinica: json['numero_historia_clinica'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      fechaNacimiento: json['fecha_nacimiento'] != null
          ? DateTime.parse(json['fecha_nacimiento'])
          : null,
      alergias: json['alergias'],
      antecedentesOculares: json['antecedentes_oculares'],
      estado: json['estado'],
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
      fechaModificacion: DateTime.parse(json['fecha_modificacion']),
      examenes: (json['examenes'] as List<dynamic>?)
              ?.map((e) => ExamenOcular.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero_historia_clinica': numeroHistoriaClinica,
      'nombre': nombre,
      'apellido': apellido,
      'fecha_nacimiento': fechaNacimiento?.toIso8601String(),
      'alergias': alergias,
      'antecedentes_oculares': antecedentesOculares,
      'estado': estado,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_modificacion': fechaModificacion.toIso8601String(),
      'examenes': examenes.map((e) => e.toJson()).toList(),
    };
  }
}

class ExamenOcular {
  final int id;
  final int paciente; // ID de paciente
  final String? agudezaVisualDerecho;
  final String? agudezaVisualIzquierdo;
  final double? presionIntraocularDerecho;
  final double? presionIntraocularIzquierdo;
  final String? diagnosticoOcular;

  ExamenOcular({
    required this.id,
    required this.paciente,
    this.agudezaVisualDerecho,
    this.agudezaVisualIzquierdo,
    this.presionIntraocularDerecho,
    this.presionIntraocularIzquierdo,
    this.diagnosticoOcular,
  });

  factory ExamenOcular.fromJson(Map<String, dynamic> json) {
    return ExamenOcular(
      id: json['id'],
      paciente: json['paciente'],
      agudezaVisualDerecho: json['agudeza_visual_derecho'],
      agudezaVisualIzquierdo: json['agudeza_visual_izquierdo'],
      presionIntraocularDerecho: json['presion_intraocular_derecho'] != null
          ? double.tryParse(json['presion_intraocular_derecho'].toString())
          : null,
      presionIntraocularIzquierdo: json['presion_intraocular_izquierdo'] != null
          ? double.tryParse(json['presion_intraocular_izquierdo'].toString())
          : null,
      diagnosticoOcular: json['diagnostico_ocular'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paciente': paciente,
      'agudeza_visual_derecho': agudezaVisualDerecho,
      'agudeza_visual_izquierdo': agudezaVisualIzquierdo,
      'presion_intraocular_derecho': presionIntraocularDerecho,
      'presion_intraocular_izquierdo': presionIntraocularIzquierdo,
      'diagnostico_ocular': diagnosticoOcular,
    };
  }
}
