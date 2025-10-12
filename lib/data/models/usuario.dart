class Usuario {
  final int id;
  final String nombre;
  final String correo;
  final String sexo;
  final DateTime fechaNacimiento;
  final String? telefono;
  final String? direccion;
  final bool estado;
  final String? rol;

  Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.sexo,
    required this.fechaNacimiento,
    this.telefono,
    this.direccion,
    required this.estado,
    this.rol,
  });

factory Usuario.fromJson(Map<String, dynamic> json) {
  return Usuario(
    id: json['id'] ?? 0,
    nombre: json['nombre'] ?? '',
    correo: json['correo'] ?? '',
    sexo: json['sexo'] ?? '',
    fechaNacimiento: DateTime.parse(json['fecha_nacimiento']),
    telefono: json['telefono'] ?? '',
    direccion: json['direccion'] ?? '',
    estado: json['estado'] ?? true,
    rol: json['rol']  
  );
}


  Map<String, dynamic> toJson() {
    
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
      'sexo': sexo,
      'fecha_nacimiento': fechaNacimiento.toIso8601String().split('T')[0],
      'telefono': telefono,
      'direccion': direccion,
      'estado': estado,
      'rol': rol,
    };
  }

  bool puedeAccederSistema() {
    // Super admin siempre puede acceder
    if (rol == 'superAdmin') {
      return true;
    }
    
    return false;
  }
}

class Rol {
  final int id;
  final String nombre;

  Rol({
    required this.id,
    required this.nombre,
  });

  factory Rol.fromJson(Map<String, dynamic> json) {
    return Rol(
      id: json['id'],
      nombre: json['nombre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }

  String get displayName {
    switch (nombre) {
      case 'paciente':
        return 'Paciente';
      case 'medico':
        return 'Médico';
      case 'administrador':
        return 'Administrador';
      case 'superAdmin':
        return 'Super Administrador';
      default:
        return nombre;
    }
  }
}

class Grupo {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? direccion;
  final String? telefono;
  final String? correo;
  final String estado;
  final DateTime fechaCreacion;
  final DateTime? fechaSuspension;

  Grupo({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.direccion,
    this.telefono,
    this.correo,
    required this.estado,
    required this.fechaCreacion,
    this.fechaSuspension,
  });

  factory Grupo.fromJson(Map<String, dynamic> json) {
    return Grupo(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      direccion: json['direccion'],
      telefono: json['telefono'],
      correo: json['correo'],
      estado: json['estado'],
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
      fechaSuspension: json['fecha_suspension'] != null
          ? DateTime.parse(json['fecha_suspension'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'direccion': direccion,
      'telefono': telefono,
      'correo': correo,
      'estado': estado,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_suspension': fechaSuspension?.toIso8601String(),
    };
  }

  String get estadoDisplay {
    switch (estado) {
      case 'ACTIVO':
        return 'Activo';
      case 'SUSPENDIDO':
        return 'Suspendido';
      case 'MOROSO':
        return 'Moroso';
      case 'CANCELADO':
        return 'Cancelado';
      default:
        return estado;
    }
  }

  bool get estaActivo => estado == 'ACTIVO';
}