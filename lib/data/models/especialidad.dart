class Especialidad {
  final int id;
  final String nombre;

  Especialidad({
    required this.id,
    required this.nombre,
  });

  factory Especialidad.fromJson(Map<String, dynamic> json) {
    return Especialidad(
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

  @override
  String toString() => '$id:$nombre';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Especialidad && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}