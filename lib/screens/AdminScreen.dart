import 'package:clinica_visionex/screens/pacientes/GestionarPacientesScreen.dart';
import 'package:clinica_visionex/screens/patologias/GestionarPatologiasScreen.dart';
import 'package:flutter/material.dart';
import './GestionarMedicoScreen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:clinica_visionex/screens/Login.dart'; // 👈 tu pantalla de login

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

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
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menú Admin',
                style: TextStyle(color: Colors.white, fontSize: 24),
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
                ListTile(
                  title: const Text('Gestionar Pacientes'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GestionarPacientesScreen(),
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
                        builder: (context) => const GestionarPatologiaScreen(),
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
