import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../../config/app.config.dart' as api;

class EspecialidadService {
  static const String baseUrl = "${api.AppConfig.apiUrl}/api/doctores/especialidades/";

  /// Obtiene todas las especialidades disponibles
  static Future<List<Especialidad>> getEspecialidades() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((e) => Especialidad.fromJson(e)).toList();
      } else {
        throw Exception('Error al obtener especialidades: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener especialidades: $e');
    }
  }

  /// Obtiene una especialidad específica por ID
  static Future<Especialidad> getEspecialidadById(int id) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl$id/"),
        headers: {"Content-Type": "application/json"},
      );
      
      if (response.statusCode == 200) {
        return Especialidad.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al obtener especialidad: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener especialidad: $e');
    }
  }

  /// Crea una nueva especialidad
  static Future<Especialidad> createEspecialidad(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Especialidad.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al crear especialidad: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión al crear especialidad: $e');
    }
  }

  /// Actualiza una especialidad existente
  static Future<Especialidad> updateEspecialidad(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse("$baseUrl$id/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 200) {
        return Especialidad.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al actualizar especialidad: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión al actualizar especialidad: $e');
    }
  }

  /// Elimina una especialidad
  static Future<void> deleteEspecialidad(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl$id/"),
        headers: {"Content-Type": "application/json"},
      );
      
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Error al eliminar especialidad: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión al eliminar especialidad: $e');
    }
  }
}