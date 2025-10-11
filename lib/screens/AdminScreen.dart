
import 'package:clinica_visionex/widgets/crud_patologias/GestionarPatologiasScreen.dart';
// =======
import 'package:clinica_visionex/screens/pacientes/GestionarPacientesScreen.dart';
// import 'package:clinica_visionex/screens/patologias/GestionarPatologiasScreen.dart';
// >>>>>>> edae325167c3f23792b20ba13293602dbe688bfa
import 'package:flutter/material.dart';
import '../widgets/crud_medicos/GestionarMedicoScreen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:clinica_visionex/screens/Login.dart'; // 👈 tu pantalla de login
import 'package:google_fonts/google_fonts.dart';
import '../widgets/common/custom_drawer.dart';
import '../widgets/common/drawer_menu_item.dart';

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

    // Configurar elementos del menú para administrador
    final List<DrawerMenuItem> adminMenuItems = [
      DrawerMenuItem(
        title: 'Gestión de Usuarios',
        icon: Icons.people_outline,
        subItems: [
          DrawerSubItem(
            title: 'Gestionar Médicos',
            icon: Icons.medical_information_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GestionarMedicoScreen(),
                ),
              );
            },
          ),
          DrawerSubItem(
            title: 'Gestionar Pacientes',
            icon: Icons.people_alt_outlined,
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
      DrawerMenuItem(
        title: 'Historial Clínico',
        icon: Icons.assignment_outlined,
        subItems: [
          DrawerSubItem(
            title: 'Gestionar Patologías',
            icon: Icons.medical_services_outlined,
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
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Panel de Administrador',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF17635F),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      drawer: CustomDrawer(
        userRole: 'Administrador',
        userEmail: correo,
        menuItems: adminMenuItems,
        onLogout: cerrarSesion,
        userIcon: Icons.admin_panel_settings,
      ),
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
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFF17635F).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.dashboard,
                          size: 48,
                          color: Color(0xFF17635F),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Bienvenido al Panel de Administrador',
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF17635F),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Utiliza el menú lateral para navegar entre las diferentes secciones de administración.',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
