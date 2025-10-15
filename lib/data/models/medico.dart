import 'usuario.dart';
import 'especialidad.dart';

class Medico {
  final Usuario medico; // Usuario base
  final String numeroColegiado;
  final List<Especialidad> especialidades;

  Medico({
    required this.medico,
    required this.numeroColegiado,
    required this.especialidades,
  });

  // Propiedades de conveniencia para acceder a datos del usuario
  int get id => medico.id;
  String get nombre => medico.nombre;
  String get correo => medico.correo;
  String get sexo => medico.sexo;
  DateTime get fechaNacimiento => medico.fechaNacimiento;
  String? get telefono => medico.telefono;
  String? get direccion => medico.direccion;
  bool get estado => medico.estado;
  String? get rol => medico.rol;

factory Medico.fromJson(Map<String, dynamic> json) {
  final ids = List<int>.from(json['especialidades'] ?? []);
  final nombres = List<String>.from(json['especialidades_nombres'] ?? []);

  final especialidades = <Especialidad>[];
  for (var i = 0; i < ids.length && i < nombres.length; i++) {
    especialidades.add(Especialidad(id: ids[i], nombre: nombres[i]));
  }

  return Medico(
    medico: Usuario(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      correo: json['correo'] ?? '',
      sexo: json['sexo'] ?? '',
      fechaNacimiento: DateTime.tryParse(json['fecha_nacimiento'] ?? '') ?? DateTime.now(),
      telefono: json['telefono'],
      direccion: json['direccion'],
      estado: json['estado'] ?? true,
      rol: json['rol_nombre'] ?? '',
    ),
    numeroColegiado: json['numero_colegiado'] ?? '',
    especialidades: especialidades,
  );
}

  Map<String, dynamic> toJson() {
    return {
      'medico': medico.toJson(),
      'numero_colegiado': numeroColegiado,
      'especialidades': especialidades.map((e) => e.toJson()).toList(),
    };
  }

  // Para crear un médico con información completa para formularios
  Map<String, dynamic> toCreateJson() {
    return {
      'numero_colegiado': numeroColegiado,
      'especialidades': especialidades.map((e) => e.id).toList(),
      // Datos del usuario
      'nombre': medico.nombre,
      'correo': medico.correo,
      'sexo': medico.sexo,
      'fecha_nacimiento':
          medico.fechaNacimiento.toIso8601String().split('T')[0],
      'telefono': medico.telefono,
      'direccion': medico.direccion,
    };
  }

  String get nombreCompleto => '$nombre';

  String get especialidadesTexto =>
      especialidades.map((e) => e.nombre).join(', ');

  List<int> get especialidadesIds => especialidades.map((e) => e.id).toList();

  @override
  String toString() => '$nombreCompleto - $numeroColegiado';
}
