import 'package:clinica_visionex/screens/patologias/GestionarPatologiasScreen.dart';
import 'package:flutter/material.dart';
import './GestionarMedicoScreen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          ],
        ),
      ),
      body: const Center(child: Text('Bienvenido al Panel de Administrador')),
    );
  }
}
