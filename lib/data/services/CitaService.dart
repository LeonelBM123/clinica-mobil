import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../../config/app.config.dart' as api;

class CitaService {
  static const String baseUrl = "${api.AppConfig.apiUrl}/api/citas";

  /// Obtiene todas las citas de un paciente
  static Future<List<CitaMedica>> getCitasPaciente(int pacienteId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/paciente/$pacienteId/"),
        headers: {"Content-Type": "application/json"},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((e) => CitaMedica.fromJson(e)).toList();
      } else {
        throw Exception('Error al obtener citas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener citas: $e');
    }
  }

  /// Obtiene bloques horarios disponibles de un médico
  static Future<List<BloqueHorario>> getBloquesHorarioMedico(int medicoId) async {
    try {
      final response = await http.get(
        Uri.parse("${api.AppConfig.apiUrl}/api/doctores/bloques-horario/medico/$medicoId/"),
        headers: {"Content-Type": "application/json"},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((e) => BloqueHorario.fromJson(e)).toList();
      } else {
        throw Exception('Error al obtener horarios: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener horarios: $e');
    }
  }

  /// Crea una nueva cita médica
  static Future<CitaMedica> crearCita(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return CitaMedica.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al crear cita: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión al crear cita: $e');
    }
  }

  /// Cancela una cita médica
  static Future<void> cancelarCita(int citaId, String motivo) async {
    try {
      final response = await http.patch(
        Uri.parse("$baseUrl/$citaId/cancelar/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"motivo_cancelacion": motivo}),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Error al cancelar cita: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión al cancelar cita: $e');
    }
  }

  /// Obtiene citas disponibles para una fecha específica
  static Future<List<String>> getHorasDisponibles(int bloqueHorarioId, String fecha) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/disponibles/?bloque_horario=$bloqueHorarioId&fecha=$fecha"),
        headers: {"Content-Type": "application/json"},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((e) => e.toString()).toList();
      } else {
        throw Exception('Error al obtener horas disponibles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener horas disponibles: $e');
    }
  }
}