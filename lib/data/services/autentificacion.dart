import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/app.config.dart' as api;

final storage = FlutterSecureStorage();

Future<Map<String, dynamic>?> login(String username, String password) async {

  final url = Uri.parse("${api.AppConfig.apiUrl}/api/usuarios/login/");
// =======
     
//      final url = Uri.parse("http://192.168.0.17:7000/api/usuarios/login/");
//    //final url = Uri.parse("http://127.0.0.1:7000/api/usuarios/login/");
// >>>>>>> edae325167c3f23792b20ba13293602dbe688bfa

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"correo": username, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Guardamos el token en secure storage
      await storage.write(key: "token", value: data["token"]);
      await storage.write(key: "rol", value: data["rol"]);
      await storage.write(
        key: "usuario_id",
        value: data["usuario_id"].toString(),
      );
      await storage.write(
        key: "usuario_id",
        value: data["usuario_id"].toString(),
      );

      print("✅ ${data['message']}");
      return data; // Devuelve el JSON completo si quieres usarlo en la UI
    } else {
      print("❌ Error en login: ${response.body}");
      return null; // Login fallido
    }
  } catch (e) {
    print("❌ Ocurrió un error: $e");
    return null;
  }
}
