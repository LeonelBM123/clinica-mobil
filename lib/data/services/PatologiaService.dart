import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/patologia.dart';
import '../../config/app.config.dart' as api;
class PatologiaService {
  static const String baseUrl = "${api.AppConfig.apiUrl}/api/patologias/";

  static Future<List<Patologia>> getPatologias() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((e) => Patologia.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener patologías: ${response.statusCode}');
    }
  }

  static Future<Patologia> createPatologia(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Patologia.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear patología: ${response.statusCode}');
    }
  }

  static Future<Patologia> updatePatologia(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await http.patch(
      Uri.parse("$baseUrl$id/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return Patologia.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar patología: ${response.statusCode}');
    }
  }

  static Future<void> deletePatologia(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl$id/"));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Error al eliminar patología: ${response.statusCode}');
    }
  }
}
