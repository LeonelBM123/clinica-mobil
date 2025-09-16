class Medico {
  final int id;
  final String nombre;
  final String numeroColegiado;
  final List<String> especialidades; // nombres para mostrar
  final List<int> especialidadesIds;  // IDs reales para enviar al backend
  final String correo;
  final String sexo;
  final String fechaNacimiento;
  final String telefono;
  final String direccion;
  final String rol;

  Medico({
    required this.id,
    required this.nombre,
    required this.numeroColegiado,
    required this.especialidades,
    required this.especialidadesIds,
    required this.correo,
    required this.sexo,
    required this.fechaNacimiento,
    required this.telefono,
    required this.direccion,
    required this.rol,
  });

  factory Medico.fromJson(Map<String, dynamic> json) => Medico(
        id: json['info_medico']['id'],
        nombre: json['info_medico']['nombre'],
        numeroColegiado: json['numero_colegiado'],
        especialidades: List<String>.from(json['especialidades_nombres']),
        especialidadesIds: List<int>.from(json['especialidades']), // IDs reales
        correo: json['info_medico']['correo'],
        sexo: json['info_medico']['sexo'],
        fechaNacimiento: json['info_medico']['fecha_nacimiento'],
        telefono: json['info_medico']['telefono'],
        direccion: json['info_medico']['direccion'],
        rol: json['info_medico']['rol'],
      );
}
