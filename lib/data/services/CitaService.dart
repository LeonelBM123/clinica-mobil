import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/models.dart';
import '../../config/app.config.dart' as api;

class CitaService {
  static const String baseUrl = "${api.AppConfig.apiUrl}/api/citas_pagos/citas-medicas";

  /// Obtiene todas las citas de un paciente
  static Future<List<CitaMedica>> getCitasPaciente(int pacienteId, [String? token]) async {
    final headers = {"Content-Type": "application/json"};
    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Token $token";
    }
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/usuario/$pacienteId/"),
        headers: headers,
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
  static Future<List<BloqueHorario>> getBloquesHorarioMedico(int medicoId, [String? token]) async {
    final url = "${api.AppConfig.apiUrl}/api/doctores/bloques-horarios/medico/$medicoId/";
    print("🔍 Solicitando bloques horarios para médico $medicoId");
    print("🔍 URL: $url");
    
    final headers = {"Content-Type": "application/json"};
    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Token $token";
    }
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      print("🔍 Response status: ${response.statusCode}");
      print("🔍 Response body: ${response.body}");
      
      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          print("⚠️ Response body está vacío");
          return [];
        }
        
        final dynamic jsonData = jsonDecode(responseBody);
        print("🔍 JSON parsed: $jsonData");
        print("🔍 JSON type: ${jsonData.runtimeType}");
        
        if (jsonData is! List) {
          print("❌ Response no es una lista: ${jsonData.runtimeType}");
          throw Exception('La respuesta del servidor no es una lista válida');
        }
        
        final List<dynamic> jsonList = jsonData;
        print("🔍 Found ${jsonList.length} bloques horarios");
        
        List<BloqueHorario> bloques = [];
        for (int i = 0; i < jsonList.length; i++) {
          try {
            final item = jsonList[i];
            print("🔍 Processing item $i: $item");
            
            if (item == null) {
              print("⚠️ Item $i es null, saltando...");
              continue;
            }
            
            if (item is! Map<String, dynamic>) {
              print("⚠️ Item $i no es un Map válido: ${item.runtimeType}");
              continue;
            }
            
            final bloque = BloqueHorario.fromJson(item);
            bloques.add(bloque);
            print("✅ Bloque $i procesado exitosamente");
          } catch (e) {
            print("❌ Error procesando item $i: $e");
            continue; // Saltar este item y continuar con los demás
          }
        }
        
        return bloques;
      } else {
        throw Exception('Error al obtener horarios: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("❌ Error en getBloquesHorarioMedico: $e");
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
        Uri.parse("$baseUrl/mi-paciente-id/"),
        headers: headers,
      );
      
      print("🔍 [Frontend] getMiPacienteId Response status: ${response.statusCode}");
      print("🔍 [Frontend] getMiPacienteId Response body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['paciente_id'] as int;
      } else {
        throw Exception('Error al obtener ID del paciente: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("❌ [Frontend] Error en getMiPacienteId: $e");
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
        print("⚠️ Error al obtener horas ocupadas: ${response.statusCode}");
        return []; // Devolver lista vacía en caso de error
      }
    } catch (e) {
      print("❌ Error al obtener horas ocupadas: $e");
      return []; // Devolver lista vacía en caso de error
    }
  }

  /// Crea una nueva cita médica
  static Future<CitaMedica> crearCita(Map<String, dynamic> data) async {

    try {
      // Obtener token de autenticación
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: "token");
      
      print("🔍 [Frontend] Creando cita con datos: $data");
      print("🔍 [Frontend] Token presente: ${token != null && token.isNotEmpty}");
      
      // Verificar que todos los valores en data no sean null problemáticos
      print("🔍 [Frontend] Verificando tipos de datos:");
      data.forEach((key, value) {
        print("   $key: ${value.runtimeType} = $value");
      });
      
      final headers = {"Content-Type": "application/json; charset=utf-8"};
      if (token != null && token.isNotEmpty) {
        headers["Authorization"] = "Token $token";
      }
      
      String jsonBody;
      try {
        jsonBody = jsonEncode(data);
        print("🔍 [Frontend] JSON body created successfully: $jsonBody");
      } catch (e) {
        print("❌ [Frontend] Error creating JSON body: $e");
        throw Exception('Error al convertir datos a JSON: $e');
      }
      
      final response = await http.post(
        Uri.parse("$baseUrl/"),
        headers: headers,
        body: jsonBody,
      );
      
      print("🔍 [Frontend] Response status: ${response.statusCode}");
      print("🔍 [Frontend] Response body: ${response.body}");
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        try {
          print("🔍 [Frontend] Raw response body: '${response.body}'");
          print("🔍 [Frontend] Response body length: ${response.body.length}");
          
          final jsonResponse = jsonDecode(response.body);
          print("🔍 [Frontend] JSON decoded successfully");
          print("🔍 [Frontend] JSON type: ${jsonResponse.runtimeType}");
          print("🔍 [Frontend] JSON content: $jsonResponse");
          
          if (jsonResponse is Map<String, dynamic>) {
            return CitaMedica.fromJson(jsonResponse);
          } else {
            throw Exception('Response is not a valid JSON object: ${jsonResponse.runtimeType}');
          }
        } catch (e, stackTrace) {
          print("❌ [Frontend] Error parsing JSON response: $e");
          print("❌ [Frontend] Stack trace: $stackTrace");
          print("❌ [Frontend] Raw response: '${response.body}'");
          throw Exception('Error al procesar la respuesta del servidor: $e');
        }
      } else {
        throw Exception('Error al crear cita: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("❌ [Frontend] Error en crearCita: $e");
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