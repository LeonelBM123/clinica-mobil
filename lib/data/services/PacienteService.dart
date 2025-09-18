import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app.config.dart' as api;
import '../models/paciente.dart';

class PacienteService {
  //  usa tu IP local en vez de 127.0.0.1
  static const String baseUrl = "${api.AppConfig.apiUrl}/api";

  /// Obtener lista de pacientes
  static Future<List<Paciente>> getPacientes() async {
    final response = await http.get(Uri.parse("$baseUrl/pacientes/"));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Paciente.fromJson(json)).toList();
    } else {
      throw Exception("Error al obtener pacientes: ${response.statusCode}");
    }
  }

  /// Obtener un paciente por ID
  static Future<Paciente> getPacienteById(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/pacientes/$id/"));

    if (response.statusCode == 200) {
      return Paciente.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Error al obtener paciente $id");
    }
  }


    
  static String? _fmtYYYYMMDD(DateTime? d) {
    if (d == null) return null;
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
      }


  /// Crear un paciente
  static Future<void> createPaciente(Paciente p) async {
    final payload = {
      'numero_historia_clinica': p.numeroHistoriaClinica,
      'nombre': p.nombre,
      'apellido': p.apellido,
      'fecha_nacimiento': _fmtYYYYMMDD(p.fechaNacimiento),
      'alergias': p.alergias,
      'antecedentes_oculares': p.antecedentesOculares,
      'estado': p.estado,
    };

  final resp = await http.post(
    Uri.parse('$baseUrl/pacientes/'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(payload),
  );

  if (resp.statusCode != 201 && resp.statusCode != 200) {
    throw Exception('Error al crear paciente: ${resp.body}');
  }
}


/// Actualizar un paciente
static Future<Paciente> updatePaciente(int id, Paciente paciente) async {
  final payload = {
    'numero_historia_clinica': paciente.numeroHistoriaClinica,
    'nombre': paciente.nombre,
    'apellido': paciente.apellido,
    'fecha_nacimiento': _fmtYYYYMMDD(paciente.fechaNacimiento),
    'alergias': paciente.alergias,
    'antecedentes_oculares': paciente.antecedentesOculares,
    'estado': paciente.estado,
  };

  final response = await http.put(
    Uri.parse("$baseUrl/pacientes/$id/"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(payload),
  );

  if (response.statusCode == 200) {
    return Paciente.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Error al actualizar paciente $id: ${response.body}");
  }
}


  /// Eliminar un paciente
  static Future<void> deletePaciente(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/pacientes/$id/"));

    if (response.statusCode != 204) {
      throw Exception("Error al eliminar paciente $id: ${response.body}");
    }
  }
}
