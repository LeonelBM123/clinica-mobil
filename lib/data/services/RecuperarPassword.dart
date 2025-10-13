import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';

class recuperarPass extends StatefulWidget {
  const recuperarPass({super.key});

  @override
  State<recuperarPass> createState() => _recuperarPassState();
}

class _recuperarPassState extends State<recuperarPass> {
  final TextEditingController correoController = TextEditingController();
  final TextEditingController tokenController = TextEditingController();
  final TextEditingController nuevaPassController = TextEditingController();

  bool mostrarTokenYPassword = false;
  bool cargando = false;

  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api/'));

  //Solicitar token de recuperación
  Future<void> solicitarToken() async {
    final correo = correoController.text.trim();

    if (correo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor ingrese su correo electrónico")),
      );
      return;
    }

    setState(() => cargando = true);

    try {
      final response = await _dio.post(
        'cuentas/usuarios/solicitar_reset_token/',
        data: {'correo': correo},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(" ${response.data['message']}"),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          mostrarTokenYPassword = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al enviar el token."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on DioException catch (e) {
      final msg = e.response?.data['error'] ?? 'Error de conexión';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(" $msg"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => cargando = false);
    }
  }

  //Cambiar contraseña
  Future<void> cambiarPassword() async {
    final correo = correoController.text.trim();
    final token = tokenController.text.trim();
    final nuevaPass = nuevaPassController.text.trim();

    if (correo.isEmpty || token.isEmpty || nuevaPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor complete todos los campos")),
      );
      return;
    }

    setState(() => cargando = true);

    try {
      final response = await _dio.post(
        'cuentas/usuarios/nueva_password/',
        data: {
          'correo': correo,
          'reset_token': token,
          'new_password': nuevaPass,
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${response.data['message']}"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); //volver al login
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error al cambiar contraseña")));
      }
    } on DioException catch (e) {
      final msg = e.response?.data['error'] ?? 'Error de conexión';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(" $msg"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Recuperar contraseña",
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF17635F),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SizedBox(height: 30),
            Text(
              "Ingresa tu correo para recibir un token de recuperación",
              style: GoogleFonts.roboto(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              controller: correoController,
              decoration: InputDecoration(
                labelText: "Correo electrónico",
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: Color(0xFF17635F),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: cargando ? null : solicitarToken,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF17635F),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child:
                  cargando
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                        "Enviar token",
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
            ),
            SizedBox(height: 40),

            if (mostrarTokenYPassword) ...[
              Divider(),
              Text(
                "Introduce el token recibido y tu nueva contraseña",
                style: GoogleFonts.roboto(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextField(
                controller: tokenController,
                decoration: InputDecoration(
                  labelText: "Token de recuperación",
                  prefixIcon: Icon(Icons.vpn_key, color: Color(0xFF17635F)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: nuevaPassController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Nueva contraseña",
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: Color(0xFF17635F),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: cargando ? null : cambiarPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF17635F),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child:
                    cargando
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                          "Cambiar contraseña",
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
