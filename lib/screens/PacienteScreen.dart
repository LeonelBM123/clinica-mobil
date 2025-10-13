import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/services/MedicoService.dart';
import '../data/models/models.dart';
import 'GestionarCitasScreen.dart';

class PacienteScreen extends StatefulWidget {
  final int usuarioId;
  final int grupoId;
  final String grupoNombre;

  const PacienteScreen({
    super.key,
    required this.usuarioId,
    required this.grupoId,
    required this.grupoNombre,
  });

  @override
  State<PacienteScreen> createState() => _PacienteScreenState();
}

class _PacienteScreenState extends State<PacienteScreen> {
  final storage = FlutterSecureStorage();
  List<Medico> medicos = [];
  bool isLoading = true;
  String? errorMessage;
  bool _mostrandoMedicos = false;

  @override
  void initState() {
    super.initState();
    _cargarMedicos();
  }

  Future<void> _cargarMedicos() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final medicosData = await MedicoService.getMedicos();
      setState(() {
        medicos = medicosData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar los médicos: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> _cerrarSesion() async {
    // Limpiar datos almacenados
    await storage.delete(key: "token");
    await storage.delete(key: "user_data");
    
    // Regresar al login
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Dashboard Paciente',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF17635F),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _cerrarSesion,
            tooltip: 'Cerrar Sesión',
          ),
        ],
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
        child: RefreshIndicator(
          onRefresh: _cargarMedicos,
          color: Color(0xFF17635F),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header de bienvenida
                Container(
                  width: double.infinity,
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
                          Icons.local_hospital,
                          size: 48,
                          color: Color(0xFF17635F),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        '¡Bienvenido!',
                        style: GoogleFonts.roboto(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF17635F),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Clínica ${widget.grupoNombre}',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Conoce a nuestro equipo médico especializado',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Sección de estadísticas rápidas
                Row(
                  children: [
                    Expanded(
                      child: _buildStatsCard(
                        'Total Médicos',
                        medicos.length.toString(),
                        Icons.medical_services,
                        Color(0xFF17635F),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildStatsCard(
                        'Especialidades',
                        _getUniqueSpecialties().toString(),
                        Icons.local_hospital,
                        Color(0xFF1976D2),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 24),
                
                // Sección de funcionalidades principales
                Text(
                  'Servicios Disponibles',
                  style: GoogleFonts.roboto(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF17635F),
                  ),
                ),
                SizedBox(height: 16),
                
                // Cards de funcionalidades
                Row(
                  children: [
                    Expanded(
                      child: _buildServiceCard(
                        'Gestionar Citas',
                        'Solicitar, ver y cancelar citas médicas',
                        Icons.event_note,
                        Color(0xFF17635F),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GestionarCitasScreen(
                              pacienteId: widget.usuarioId,
                              grupoId: widget.grupoId,
                              grupoNombre: widget.grupoNombre,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildServiceCard(
                        'Nuestros Médicos',
                        'Conoce a nuestro equipo médico',
                        Icons.medical_services,
                        Color(0xFF1976D2),
                        () => _mostrarMedicos(),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildServiceCard(
                        'Mi Historial',
                        'Ver historial médico y diagnósticos',
                        Icons.assignment,
                        Color(0xFF9C27B0),
                        () => _mostrarHistorial(),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildServiceCard(
                        'Emergencias',
                        'Información de contacto de emergencia',
                        Icons.emergency,
                        Color(0xFFE91E63),
                        () => _mostrarEmergencias(),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 24),
                
                // Sección de médicos (contraída por defecto)
                if (_mostrandoMedicos) ...[
                  Text(
                    'Nuestro Equipo Médico',
                    style: GoogleFonts.roboto(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF17635F),
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  if (isLoading)
                    _buildLoadingCard()
                  else if (errorMessage != null)
                    _buildErrorCard()
                  else if (medicos.isEmpty)
                    _buildEmptyCard()
                  else
                    ...medicos.take(3).map((medico) => _buildMedicoCard(medico)).toList(),
                  
                  if (medicos.length > 3) ...[
                    SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => _verTodosMedicos(),
                        child: Text(
                          'Ver todos los médicos (${medicos.length})',
                          style: GoogleFonts.roboto(
                            color: Color(0xFF17635F),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              icon,
              size: 24,
              color: color,
            ),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF17635F)),
            ),
            SizedBox(height: 16),
            Text(
              'Cargando médicos...',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          SizedBox(height: 16),
          Text(
            'Error al cargar',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 8),
          Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _cargarMedicos,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF17635F),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: Icon(Icons.refresh),
            label: Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No hay médicos disponibles',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Próximamente se agregarán médicos a esta clínica',
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  int _getUniqueSpecialties() {
    Set<String> especialidades = {};
    for (var medico in medicos) {
      for (var especialidad in medico.especialidades) {
        especialidades.add(especialidad.nombre);
      }
    }
    return especialidades.length;
  }

  Widget _buildServiceCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarMedicos() {
    setState(() {
      _mostrandoMedicos = !_mostrandoMedicos;
    });
  }

  void _verTodosMedicos() {
    // Navegación a una pantalla dedicada con todos los médicos
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Todos los Médicos'),
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: medicos.length,
            itemBuilder: (context, index) {
              final medico = medicos[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(0xFF17635F),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text('Dr. ${medico.nombre}'),
                subtitle: Text(
                  medico.especialidades.isNotEmpty 
                      ? medico.especialidades.map((e) => e.nombre).join(', ')
                      : 'Especialidad general',
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _mostrarHistorial() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mi Historial'),
        content: Text('Funcionalidad en desarrollo...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _mostrarEmergencias() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contactos de Emergencia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📞 Urgencias: 911'),
            SizedBox(height: 8),
            Text('🏥 Clínica ${widget.grupoNombre}'),
            Text('📞 Central: (555) 123-4567'),
            SizedBox(height: 8),
            Text('⚠️ En caso de emergencia oftalmológica, contacta inmediatamente.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicoCard(Medico medico) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del médico
            Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF17635F),
                        Color(0xFF17635F).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(35),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 35,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. ${medico.nombre}',
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFF17635F).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          medico.especialidades.isNotEmpty 
                              ? medico.especialidades.map((e) => e.nombre).join(', ')
                              : 'Especialidad general',
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: Color(0xFF17635F),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20),
            
            // Información de contacto
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildContactRow(
                    Icons.email_outlined,
                    'Correo',
                    medico.correo,
                  ),
                  SizedBox(height: 12),
                  _buildContactRow(
                    Icons.phone_outlined,
                    'Teléfono',
                    medico.telefono ?? 'No disponible',
                  ),
                  if (medico.direccion != null && medico.direccion!.isNotEmpty) ...[
                    SizedBox(height: 12),
                    _buildContactRow(
                      Icons.location_on_outlined,
                      'Dirección',
                      medico.direccion!,
                      isLast: true,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF17635F).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Color(0xFF17635F),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}