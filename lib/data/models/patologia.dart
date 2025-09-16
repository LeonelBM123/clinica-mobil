class Patologia {
  final int id;
  final String nombre;
  final String alias;
  final String descripcion;
  final String gravedad;

  Patologia({
    required this.id,
    required this.nombre,
    required this.alias,
    required this.descripcion,
    required this.gravedad,
  });

  factory Patologia.fromJson(Map<String, dynamic> json) => Patologia(
    id: json['id'],
    nombre: json['nombre'],
    alias: json['alias'],
    descripcion: json['descripcion'],
    gravedad: json['gravedad'],
  );
}
