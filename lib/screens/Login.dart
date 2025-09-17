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
                Image.asset('lib/assets/images/logo.png',
                  width: 150,
                  height: 150,),
                SizedBox( height: 15),
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
                SizedBox( height: 15),
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
                }, child: Text('Ingresar',style: TextStyle(color: Colors.white),),
                
                  style: TextButton.styleFrom(backgroundColor: Color.fromARGB(255, 23, 99, 95)),
                ),
                TextButton(onPressed: ()=>{}, child: Text('Registrate')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
