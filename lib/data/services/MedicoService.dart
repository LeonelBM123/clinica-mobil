import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/medico.dart';

class MedicoService {
 
  //static const String baseUrl = "http://192.168.1.111:8000/api/medicos/";
  static const String baseUrl = "http://192.168.0.17:7000/api/medicos/";
  static Future<List<Medico>> getMedicos() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((e) => Medico.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener médicos: ${response.statusCode}');
    }
  }

  static Future<Medico> createMedico(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Medico.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear médico: ${response.statusCode}');
    }
  }

  static Future<Medico> updateMedico(int id, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse("$baseUrl$id/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return Medico.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar médico: ${response.statusCode}');
    }
  }

  static Future<void> deleteMedico(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl$id/"));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Error al eliminar médico: ${response.statusCode}');
    }
  }
}
