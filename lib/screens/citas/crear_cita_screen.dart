import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/models.dart';
import '../../data/services/CitaService.dart';
import '../../data/services/MedicoService.dart';

class CrearCitaScreen extends StatefulWidget {
  final int pacienteId;
  final int grupoId;
  final String grupoNombre;

  const CrearCitaScreen({
    super.key,
    required this.pacienteId,
    required this.grupoId,
    required this.grupoNombre,
  });

  @override
  State<CrearCitaScreen> createState() => _CrearCitaScreenState();
}

class _CrearCitaScreenState extends State<CrearCitaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notasController = TextEditingController();
  final storage = const FlutterSecureStorage();
  
  List<Medico> _medicosDisponibles = [];
  List<BloqueHorario> _bloquesDisponibles = [];
  List<String> _horasDisponibles = [];
  
  Medico? _medicoSeleccionado;
  BloqueHorario? _bloqueSeleccionado;
  DateTime? _fechaSeleccionada;
  String? _horaSeleccionada;
  
  bool _isLoadingMedicos = true;
  bool _isLoadingBloques = false;
  bool _isLoadingHoras = false;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _cargarMedicos();
  }

  @override
  void dispose() {
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _cargarMedicos() async {
    try {
      setState(() {
        _isLoadingMedicos = true;
      });
      
      final medicos = await MedicoService.getMedicos(await storage.read(key: "token") ?? "");
      
      setState(() {
        _medicosDisponibles = medicos;
        _isLoadingMedicos = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMedicos = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar médicos: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Reintentar',
              onPressed: _cargarMedicos,
            ),
          ),
        );
      }
    }
  }

  Future<void> _cargarBloquesHorario(Medico medico) async {
    try {
      setState(() {
        _isLoadingBloques = true;
        _bloquesDisponibles = [];
        _bloqueSeleccionado = null;
        _fechaSeleccionada = null;
        _horasDisponibles = [];
        _horaSeleccionada = null;
      });
      
      final bloques = await CitaService.getBloquesHorarioMedico(medico.id);
      
      setState(() {
        _bloquesDisponibles = bloques;
        _isLoadingBloques = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingBloques = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar horarios: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _cargarHorasDisponibles() async {
    if (_bloqueSeleccionado == null || _fechaSeleccionada == null) return;
    
    try {
      setState(() {
        _isLoadingHoras = true;
        _horasDisponibles = [];
        _horaSeleccionada = null;
      });
      
      final fechaStr = _fechaSeleccionada!.toIso8601String().split('T')[0];
      final horas = await CitaService.getHorasDisponibles(_bloqueSeleccionado!.id, fechaStr);
      
      setState(() {
        _horasDisponibles = horas;
        _isLoadingHoras = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingHoras = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar horas disponibles: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _seleccionarFecha() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: today.add(Duration(days: 1)),
      firstDate: today,
      lastDate: today.add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF17635F),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _fechaSeleccionada = picked;
        _horasDisponibles = [];
        _horaSeleccionada = null;
      });
      
      await _cargarHorasDisponibles();
    }
  }

  Future<void> _crearCita() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_medicoSeleccionado == null) {
      _mostrarError('Por favor selecciona un médico');
      return;
    }
    
    if (_bloqueSeleccionado == null) {
      _mostrarError('Por favor selecciona un bloque horario');
      return;
    }
    
    if (_fechaSeleccionada == null) {
      _mostrarError('Por favor selecciona una fecha');
      return;
    }
    
    if (_horaSeleccionada == null) {
      _mostrarError('Por favor selecciona una hora disponible');
      return;
    }

    setState(() => _isCreating = true);

    try {
      // Calcular hora de fin
      final parts = _horaSeleccionada!.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final horaInicioDt = DateTime(2000, 1, 1, h, m);
      final dur = _bloqueSeleccionado!.duracionCitaMinutos;
      final horaFinDt = horaInicioDt.add(Duration(minutes: dur));
      final horaFinStr = '${horaFinDt.hour.toString().padLeft(2, '0')}:${horaFinDt.minute.toString().padLeft(2, '0')}';

      final data = {
        'fecha': _fechaSeleccionada!.toIso8601String().split('T')[0],
        'hora_inicio': _horaSeleccionada,
        'hora_fin': horaFinStr,
        'notas': _notasController.text.trim(),
        'paciente': widget.pacienteId,
        'bloque_horario': _bloqueSeleccionado!.id,
      };

      await CitaService.crearCita(data);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cita creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Retorna true para indicar que se creó
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear la cita: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isCreating = false);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Nueva Cita Médica',
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con información del paciente
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFF17635F).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.local_hospital,
                              color: Color(0xFF17635F),
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Clínica ${widget.grupoNombre}',
                                  style: GoogleFonts.roboto(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF17635F),
                                  ),
                                ),
                                Text(
                                  'Solicitar nueva cita médica',
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // Formulario
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información de la Cita',
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF17635F),
                        ),
                      ),
                      SizedBox(height: 24),

                      // Selector de médico
                      Text(
                        'Médico *',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _isLoadingMedicos
                            ? Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF17635F)),
                                  ),
                                ),
                              )
                            : DropdownButtonHideUnderline(
                                child: DropdownButton<Medico>(
                                  value: _medicoSeleccionado,
                                  isExpanded: true,
                                  hint: Text('Selecciona un médico'),
                                  items: _medicosDisponibles.map((medico) {
                                    return DropdownMenuItem(
                                      value: medico,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            medico.nombreCompleto,
                                            style: GoogleFonts.roboto(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            medico.especialidadesTexto,
                                            style: GoogleFonts.roboto(
                                              fontSize: 12,
                                              color: Color(0xFF17635F),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (medico) async {
                                    setState(() {
                                      _medicoSeleccionado = medico;
                                    });
                                    if (medico != null) {
                                      await _cargarBloquesHorario(medico);
                                    }
                                  },
                                ),
                              ),
                      ),

                      SizedBox(height: 24),

                      // Selector de bloque horario
                      Text(
                        'Bloque Horario *',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _isLoadingBloques
                            ? Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF17635F)),
                                  ),
                                ),
                              )
                            : DropdownButtonHideUnderline(
                                child: DropdownButton<BloqueHorario>(
                                  value: _bloqueSeleccionado,
                                  isExpanded: true,
                                  hint: Text(_medicoSeleccionado == null 
                                      ? 'Primero selecciona un médico' 
                                      : 'Selecciona un bloque horario'),
                                  items: _bloquesDisponibles.map((bloque) {
                                    return DropdownMenuItem(
                                      value: bloque,
                                      child: Text(
                                        '${bloque.diaSemanaDisplay} • ${bloque.horarioDisplay}',
                                        style: GoogleFonts.roboto(),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: _medicoSeleccionado == null ? null : (bloque) async {
                                    setState(() {
                                      _bloqueSeleccionado = bloque;
                                      _fechaSeleccionada = null;
                                      _horasDisponibles = [];
                                      _horaSeleccionada = null;
                                    });
                                  },
                                ),
                              ),
                      ),

                      SizedBox(height: 24),

                      // Selector de fecha
                      Text(
                        'Fecha *',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _bloqueSeleccionado == null ? null : _seleccionarFecha,
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(Icons.calendar_today, size: 20),
                          label: Text(
                            _fechaSeleccionada == null
                                ? (_bloqueSeleccionado == null 
                                    ? 'Primero selecciona un bloque horario'
                                    : 'Seleccionar fecha')
                                : _fechaSeleccionada!.toIso8601String().split('T')[0],
                            style: GoogleFonts.roboto(),
                          ),
                        ),
                      ),

                      SizedBox(height: 24),

                      // Selector de hora
                      Text(
                        'Hora Disponible *',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _isLoadingHoras
                            ? Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF17635F)),
                                  ),
                                ),
                              )
                            : DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _horaSeleccionada,
                                  isExpanded: true,
                                  hint: Text(_fechaSeleccionada == null 
                                      ? 'Primero selecciona una fecha'
                                      : (_horasDisponibles.isEmpty 
                                          ? 'No hay horas disponibles'
                                          : 'Selecciona una hora')),
                                  items: _horasDisponibles.map((hora) {
                                    return DropdownMenuItem(
                                      value: hora,
                                      child: Text(
                                        hora,
                                        style: GoogleFonts.roboto(),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: _horasDisponibles.isEmpty ? null : (hora) {
                                    setState(() {
                                      _horaSeleccionada = hora;
                                    });
                                  },
                                ),
                              ),
                      ),

                      SizedBox(height: 24),

                      // Campo de notas
                      Text(
                        'Notas (Opcional)',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _notasController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Describe brevemente el motivo de la consulta...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFF17635F)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32),

                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isCreating ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey[400]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isCreating ? null : _crearCita,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF17635F),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isCreating
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Solicitar Cita',
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}