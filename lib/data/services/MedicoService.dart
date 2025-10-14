import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../../config/app.config.dart' as api;

class MedicoService {
  static const String baseUrl = "${api.AppConfig.apiUrl}/api/doctores/medicos/";

  // Obtener todos los médicos con token
  static Future<List<Medico>> getMedicos(String token) async {
    print("🔍 Calling getMedicos with token: ${token.isNotEmpty ? 'Token provided' : 'No token'}");
    print("🔍 URL: $baseUrl");
    
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    print("🔍 Response status: ${response.statusCode}");
    print("🔍 Response body: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      print("🔍 Found ${jsonData.length} médicos");
      return jsonData.map((e) => Medico.fromJson(e)).toList();
    } else if (response.statusCode == 403) {
      throw Exception('Sin permisos para ver médicos');
    } else if (response.statusCode == 401) {
      throw Exception('No autenticado. Token inválido o expirado');
    } else {
      throw Exception('Error al obtener médicos: ${response.statusCode}');
    }
  }

  static Future<Medico> createMedico(String token, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Medico.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear médico: ${response.statusCode}');
    }
  }

  static Future<Medico> updateMedico(String token, int id, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse("$baseUrl$id/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return Medico.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar médico: ${response.statusCode}');
    }
  }

  static Future<void> deleteMedico(String token, int id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl$id/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Error al eliminar médico: ${response.statusCode}');
    }
  }
}
