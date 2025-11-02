import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/models.dart';
import '../../config/app.config.dart' as api;

class CitaService {
  /// Obtiene el ID de historia diagnóstico del paciente asociado al usuario actual
  static Future<int> getIdHistoriaDiagnosticoPaciente() async {
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: "token");
      final headers = {"Content-Type": "application/json"};
      if (token != null && token.isNotEmpty) {
        headers["Authorization"] = "Token $token";
      }
      // TODO: Cambia el endpoint por el correcto si es diferente
      final response = await http.get(
        Uri.parse("${api.AppConfig.apiUrl}/api/diagnosticos/pacientes/"),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> pacientes = jsonDecode(response.body);
        final usuarioId = int.parse(await storage.read(key: "usuario_id") ?? "0");
        final paciente = pacientes.firstWhere((p) => p["usuario"] == usuarioId, orElse: () => null);
        if (paciente != null) {
          return paciente["id"] as int;
        } else {
          throw Exception("No se encontró paciente para el usuario actual");
        }
      } else {
        throw Exception('Error al obtener ID de historia diagnóstico: ' + response.statusCode.toString() + ' - ' + response.body);
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener ID de historia diagnóstico: $e');
    }
  }
  static const String baseUrl = "${api.AppConfig.apiUrl}/api/citas_pagos/citas";

  /// Obtiene todas las citas de un paciente
  static Future<List<CitaMedica>> getCitasPaciente(int pacienteId, [String? token]) async {
    
    final headers = {"Content-Type": "application/json"};
    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Token $token";
    } else {
    }
    try {
      final url = "$baseUrl/paciente/$pacienteId/";
      print("🔍 [CitaService] Cargando citas para paciente ID: $pacienteId");
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        print("🔍 [CitaService] Citas recibidas del servidor: $jsonData");
        final citas = jsonData.map((e) => CitaMedica.fromJson(e)).toList();
        
        return citas;
      } else {
        throw Exception('Error al obtener citas: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener citas: $e');
    }
  }

  /// Obtiene bloques horarios disponibles de un médico
  static Future<List<BloqueHorario>> getBloquesHorarioMedico(int medicoId, [String? token]) async {
    final url = "${api.AppConfig.apiUrl}/api/doctores/bloques-horarios/medico/$medicoId/";
    final headers = {"Content-Type": "application/json"};
    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Token $token";
    }
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
    
      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          return [];
        }
        
        final dynamic jsonData = jsonDecode(responseBody);
        if (jsonData is! List) {
          throw Exception('La respuesta del servidor no es una lista válida');
        }
        
        final List<dynamic> jsonList = jsonData;

        List<BloqueHorario> bloques = [];
        for (int i = 0; i < jsonList.length; i++) {
          try {
            final item = jsonList[i];
            if (item == null) {
              continue;
            }
            
            if (item is! Map<String, dynamic>) {
              continue;
            }
            
            final bloque = BloqueHorario.fromJson(item);
            bloques.add(bloque);
          } catch (e) {
            continue; // Saltar este item y continuar con los demás
          }
        }
        
        return bloques;
      } else {
        throw Exception('Error al obtener horarios: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener horarios: $e');
    }
  }

  /// Obtiene el ID del paciente asociado al usuario actual
  static Future<int> getMiPacienteId() async {
    try {
      // Obtener token de autenticación
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: "token");
      final headers = {"Content-Type": "application/json"};
      if (token != null && token.isNotEmpty) {
        headers["Authorization"] = "Token $token";
      }
      final response = await http.get(
        Uri.parse("${api.AppConfig.apiUrl}/api/diagnosticos/pacientes/"),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> pacientes = jsonDecode(response.body);
        final usuarioId = int.parse(await storage.read(key: "usuario_id") ?? "0");
        final paciente = pacientes.firstWhere((p) => p["usuario"] == usuarioId, orElse: () => null);
        if (paciente != null) {
          return paciente["id"] as int;
        } else {
          throw Exception("No se encontró paciente para el usuario actual");
        }
      } else {
        throw Exception('Error al obtener ID del paciente: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener ID del paciente: $e');
    }
  }

  /// Obtiene las horas ocupadas para un bloque y fecha específicos
  static Future<List<String>> getHorasOcupadas(int bloqueHorarioId, String fecha) async {
    try {
      // Obtener token de autenticación
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: "token");
      
      final headers = {"Content-Type": "application/json"};
      if (token != null && token.isNotEmpty) {
        headers["Authorization"] = "Token $token";
      }
      
      final response = await http.get(
        Uri.parse("$baseUrl/?bloque_horario=$bloqueHorarioId&fecha=$fecha"),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((cita) => cita['hora_inicio'] as String).toList();
      } else {
        return []; // Devolver lista vacía en caso de error
      }
    } catch (e) {
      return []; // Devolver lista vacía en caso de error
    }
  }

  /// Crea una nueva cita médica
  static Future<CitaMedica> crearCita(Map<String, dynamic> data) async {

    try {
      // Obtener token de autenticación
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: "token");
      // Verificar que todos los valores en data no sean null problemáticos
      data.forEach((key, value) {
        if (value == null) {
          print("❌ [Frontend] El valor de $key es null");
        }
      });
      final headers = {"Content-Type": "application/json; charset=utf-8"};
      if (token != null && token.isNotEmpty) {
        headers["Authorization"] = "Token $token";
      }
      String jsonBody;
      try {
        jsonBody = jsonEncode(data);
      } catch (e) {
        throw Exception('Error al convertir datos a JSON: $e');
      }
      print("\n================= [CitaService] CREAR CITA =================");
      print("URL: $baseUrl/");
      print("HEADERS: $headers");
      print("BODY: $jsonBody");
      print("===========================================================\n");
      final response = await http.post(
        Uri.parse("$baseUrl/"),
        headers: headers,
        body: jsonBody,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        try {
          
          final jsonResponse = jsonDecode(response.body);

          if (jsonResponse is Map<String, dynamic>) {
            return CitaMedica.fromJson(jsonResponse);
          } else {
            throw Exception('Response is not a valid JSON object: ${jsonResponse.runtimeType}');
          }
        } catch (e, stackTrace) {
          throw Exception('Error al procesar la respuesta del servidor: $e');
        }
      } else {
        throw Exception('Error al crear cita: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión al crear cita: $e');
    }
  }

  /// Cancela una cita médica
  static Future<void> cancelarCita(int citaId, String motivo) async {
    print(citaId.toString());
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: "token");      
      final response = await http.delete(
        Uri.parse("$baseUrl/$citaId/"),
        headers: {"Content-Type": "application/json",
                  "Authorization": "Token $token"},
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
      // Obtener token de autenticación
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: "token");
      
      final headers = {"Content-Type": "application/json"};
      if (token != null && token.isNotEmpty) {
        headers["Authorization"] = "Token $token";
      }
      
      final response = await http.get(
        Uri.parse("$baseUrl/disponibles/?bloque_horario=$bloqueHorarioId&fecha=$fecha"),
        headers: headers,
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