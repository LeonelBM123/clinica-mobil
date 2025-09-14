import 'package:clinica_visionex/data/services/autentificacion.dart' as autentificacion;
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            width: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Clinica Visionex'),
                SizedBox( height: 15),

                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "Correo",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),),
                  ),
                ),
                SizedBox( height: 15),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Contraseña",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),),
                  ),
                ),
                TextButton(onPressed: () async {
                  final email = emailController.text.trim();
                  final password = passwordController.text.trim();
                  final result = await autentificacion.login(email, password);
                  if (result?['rol']=='Administrador') {
                    Navigator.pushNamed(context, '/AdminScreen');
                  }
                  if (result?['rol']=='Medico') {
                    Navigator.pushNamed(context, '/MedicoScreen');
                  }
                  if (result?['rol']=='Paciente') {
                    Navigator.pushNamed(context, '/PacienteScreen');
                  }
                }, child: Text('Ingresar')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
