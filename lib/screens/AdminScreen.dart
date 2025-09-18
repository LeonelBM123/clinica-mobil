import 'package:clinica_visionex/widgets/crud_patologias/GestionarPatologiasScreen.dart';
import 'package:flutter/material.dart';
import '../widgets/crud_medicos/GestionarMedicoScreen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:clinica_visionex/screens/Login.dart'; // 👈 tu pantalla de login

class AdminScreen extends StatelessWidget {
  final String? correo;
  const AdminScreen({super.key, this.correo});
  
  @override
  Widget build(BuildContext context) {
    final storage = const FlutterSecureStorage();
    Future<void> cerrarSesion() async {
      // Eliminar datos guardados en el login
      await storage.deleteAll();

      // Redirigir al login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Administrador')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 16, 110, 106), // Color principal
              ),
              accountName: const Text(
                "Administrador",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              accountEmail: Text(correo ?? "Sin correo"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.teal),
              ),
            ),
            ExpansionTile(
              title: const Text('Gestionar Usuarios'),
              children: [
                ListTile(
                  title: const Text('Gestionar Médicos'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GestionarMedicoScreen(),
                      ),
                    );
                  },
                ),
              ],
              
            ),
            ExpansionTile(
              title: const Text('Historial Clínico y Diagnósticos'),
              children: [
                ListTile(
                  title: const Text('Gestionar Patologias'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => const GestionarPatologiaScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const Divider(),
    
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar Sesión'),
              onTap: () async {
                await cerrarSesion();
              },
            ),
          ],
        ),
      ),
      body: const Center(child: Text('Bienvenido al Panel de Administrador')),
    );
  }
}
