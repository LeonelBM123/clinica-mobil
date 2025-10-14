import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/services/CitaService.dart';
import '../data/services/MedicoService.dart';
import '../data/models/models.dart';
import 'citas/crear_cita_screen.dart';

class GestionarCitasScreen extends StatefulWidget {
  final int pacienteId;
  final int grupoId;
  final String grupoNombre;

  const GestionarCitasScreen({
    super.key,
    required this.pacienteId,
    required this.grupoId,
    required this.grupoNombre,
  });

  @override
  State<GestionarCitasScreen> createState() => _GestionarCitasScreenState();
}

class _GestionarCitasScreenState extends State<GestionarCitasScreen> {
  List<CitaMedica> citas = [];
  List<Medico> medicos = [];
  bool isLoading = true;
  String? errorMessage;
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final citasData = await CitaService.getCitasPaciente(widget.pacienteId);
      final medicosData = await MedicoService.getMedicos(await storage.read(key: "token") ?? "");

      setState(() {
        citas = citasData;
        medicos = medicosData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        if (e == 404) {
          errorMessage = 'Error al cargar datos: no se encontraron datos';
        }
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Gestionar Citas',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF17635F),
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
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
          onRefresh: _cargarDatos,
          color: Color(0xFF17635F),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Botón para nueva cita
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _mostrarDialogoNuevaCita(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF17635F),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    icon: Icon(Icons.add, size: 24),
                    label: Text(
                      'Solicitar Nueva Cita',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // Estadísticas rápidas
                Row(
                  children: [
                    Expanded(
                      child: _buildStatsCard(
                        'Citas Activas',
                        citas.where((c) => c.estado).length.toString(),
                        Icons.event_available,
                        Color(0xFF17635F),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildStatsCard(
                        'Médicos Disponibles',
                        medicos.length.toString(),
                        Icons.medical_services,
                        Color(0xFF1976D2),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24),

                // Título de mis citas
                Text(
                  'Mis Citas Médicas',
                  style: GoogleFonts.roboto(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF17635F),
                  ),
                ),
                SizedBox(height: 16),

                // Lista de citas
                if (isLoading)
                  _buildLoadingCard()
                else if (errorMessage != null)
                  _buildErrorCard()
                else if (citas.isEmpty)
                  _buildEmptyCard()
                else
                  ...citas.map((cita) => _buildCitaCard(cita)).toList(),
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

  Widget _buildCitaCard(CitaMedica cita) {
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
            // Header de la cita
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cita.estado ? Color(0xFF17635F).withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    cita.estado ? Icons.event_available : Icons.event_busy,
                    color: cita.estado ? Color(0xFF17635F) : Colors.red,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cita.nombreMedico ?? 'Médico no especificado',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        cita.especialidadMedico ?? 'Especialidad general',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Color(0xFF17635F),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: cita.estado ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    cita.estadoTexto,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: cita.estado ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Información de la cita
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Text(
                        'Fecha: ${cita.fecha}',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Text(
                        'Hora: ${cita.horaInicio} - ${cita.horaFin}',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (cita.notas != null && cita.notas!.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.note, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Notas: ${cita.notas}',
                            style: GoogleFonts.roboto(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Botón de cancelar solo si está activa
            if (cita.estado) ...[
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _cancelarCita(cita),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(Icons.cancel, size: 18),
                  label: Text('Cancelar Cita'),
                ),
              ),
            ],
          ],
        ),
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
              'Cargando citas...',
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
          Icon(Icons.error_outline, size: 48, color: Colors.red),
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
            onPressed: _cargarDatos,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF17635F),
              foregroundColor: Colors.white,
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
          Icon(Icons.event_note, size: 48, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No tienes citas programadas',
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Solicita tu primera cita médica',
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoNuevaCita() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearCitaScreen(
          pacienteId: widget.pacienteId,
          grupoId: widget.grupoId,
          grupoNombre: widget.grupoNombre,
        ),
      ),
    );
    
    // Si se creó una cita, recargar los datos
    if (result == true) {
      await _cargarDatos();
    }
  }

  void _cancelarCita(CitaMedica cita) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancelar Cita'),
        content: Text('¿Estás seguro de que deseas cancelar esta cita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // TODO: Implementar cancelación de cita
              try {
                await CitaService.cancelarCita(cita.id!, 'Cancelada por el paciente');
                _cargarDatos();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cita cancelada exitosamente')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al cancelar cita: $e')),
                );
              }
            },
            child: Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }
}