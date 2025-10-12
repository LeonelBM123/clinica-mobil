import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../../config/app.config.dart' as api;

class UsuarioService {
  static const String baseUrl = "${api.AppConfig.apiUrl}/api/cuentas/usuarios/";

  /// Obtiene todos los usuarios
  static Future<List<Usuario>> getUsuarios() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((e) => Usuario.fromJson(e)).toList();
      } else {
        throw Exception('Error al obtener usuarios: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener usuarios: $e');
    }
  }

  /// Obtiene un usuario específico por ID
  static Future<Usuario> getUsuarioById(int id) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl$id/"),
        headers: {"Content-Type": "application/json"},
      );
      
      if (response.statusCode == 200) {
        return Usuario.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Usuario no encontrado');
      } else {
        throw Exception('Error al obtener usuario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener usuario: $e');
    }
  }

  /// Obtiene los datos del usuario autenticado actual
  static Future<Usuario> getUsuarioActual() async {
    try {
      final response = await http.get(
        Uri.parse("${baseUrl}perfil/"),
        headers: {"Content-Type": "application/json"},
      );
      
      if (response.statusCode == 200) {
        return Usuario.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al obtener perfil del usuario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener perfil: $e');
    }
  }

  /// Actualiza los datos del usuario autenticado
  static Future<Usuario> updateUsuarioActual(Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse("${baseUrl}perfil/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 200) {
        return Usuario.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw Exception('Datos inválidos: ${errorData['message'] ?? 'Error de validación'}');
      } else {
        throw Exception('Error al actualizar perfil: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión al actualizar perfil: $e');
    }
  }

  /// Crea un nuevo usuario (solo para administradores)
  static Future<Usuario> createUsuario(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Usuario.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw Exception('Datos inválidos: ${errorData['message'] ?? 'Error de validación'}');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para crear usuarios');
      } else {
        throw Exception('Error al crear usuario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión al crear usuario: $e');
    }
  }

  /// Actualiza un usuario específico (solo para administradores)
  static Future<Usuario> updateUsuario(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse("$baseUrl$id/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 200) {
        return Usuario.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para editar este usuario');
      } else if (response.statusCode == 404) {
        throw Exception('Usuario no encontrado');
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw Exception('Datos inválidos: ${errorData['message'] ?? 'Error de validación'}');
      } else {
        throw Exception('Error al actualizar usuario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión al actualizar usuario: $e');
    }
  }

  /// Elimina un usuario (solo para administradores)
  static Future<void> deleteUsuario(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl$id/"),
        headers: {"Content-Type": "application/json"},
      );
      
      if (response.statusCode != 204 && response.statusCode != 200) {
        if (response.statusCode == 403) {
          throw Exception('No tienes permisos para eliminar usuarios');
        } else if (response.statusCode == 404) {
          throw Exception('Usuario no encontrado');
        } else {
          throw Exception('Error al eliminar usuario: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error de conexión al eliminar usuario: $e');
    }
  }
}