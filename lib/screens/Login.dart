import 'package:clinica_visionex/data/services/autentificacion.dart'
    as autentificacion;
import 'package:clinica_visionex/screens/AdminScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../widgets/common/app_animations.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 130, 130, 130),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.grey[100]!,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.08), // Espaciado responsive
                
                // Logo y título con animaciones
                AppAnimations.fadeIn(
                  delay: Duration(milliseconds: 200),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFF17635F).withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color(0xFF17635F).withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Image.asset(
                      'lib/assets/images/logo.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                AppAnimations.slideFromBottom(
                  delay: Duration(milliseconds: 400),
                  child: Text(
                    'Clinica Visionex',
                    style: AppTextStyles.heading2,
                  ),
                ),
                AppAnimations.slideFromBottom(
                  delay: Duration(milliseconds: 600),
                  child: Text(
                    'Bienvenido de vuelta',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(height: 40),

                // Formulario con animación
                AppAnimations.slideFromBottom(
                  delay: Duration(milliseconds: 800),
                  child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Campo Email
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.roboto(),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[50],
                          hintText: "Correo electrónico",
                          hintStyle: GoogleFonts.roboto(color: Colors.grey[600]),
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: Color(0xFF17635F),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      
                      // Campo Contraseña
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        style: GoogleFonts.roboto(),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[50],
                          hintText: "Contraseña",
                          hintStyle: GoogleFonts.roboto(color: Colors.grey[600]),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Color(0xFF17635F),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                      
                      // ¿Olvidó su contraseña?
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Acción para recuperar contraseña
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Función próximamente disponible')),
                            );
                          },
                          child: Text(
                            '¿Olvidó su contraseña?',
                            style: GoogleFonts.roboto(
                              color: Color(0xFF17635F),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      
                      // Botón Ingresar con animación
                      AppAnimations.scaleButton(
                        onPressed: () async {
                          final email = emailController.text.trim();
                          final password = passwordController.text.trim();
                          
                          if (email.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Por favor complete todos los campos')),
                            );
                            return;
                          }
                          
                          final result = await autentificacion.login(email, password);
                          if (result?['rol'] == 'Administrador') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminScreen(correo: email),
                              ),
                            );
                          } else if (result?['rol'] == 'Medico') {
                            Navigator.pushNamed(context, '/MedicoScreen');
                          } else if (result?['rol'] == 'Paciente') {
                            Navigator.pushNamed(context, '/PacienteScreen');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Credenciales incorrectas')),
                            );
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(
                            color: Color(0xFF17635F),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 0,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Ingresar',
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ), // Cierre de AppAnimations.slideFromBottom para el formulario
                
                SizedBox(height: 30),
                
                // Botón Registrarse
                Container(
                  width: double.infinity,
                  height: 54,
                  child: AppAnimations.scaleButton(
                    onPressed: () {
                      // Acción para registrarse
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Función de registro próximamente disponible')),
                      );
                    },
                    child: OutlinedButton(
                      onPressed: () {
                        // Acción para registrarse
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Función de registro próximamente disponible')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xFF17635F), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Crear cuenta nueva',
                        style: GoogleFonts.roboto(
                          color: Color(0xFF17635F),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: screenHeight * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
