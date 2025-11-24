
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../data/models/models.dart';
import '../../data/services/CitaService.dart';
import '../../data/services/MedicoService.dart';

class CrearCitaScreen extends StatefulWidget {
  final int grupoId;
  final String grupoNombre;

  const CrearCitaScreen({
    super.key,
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
  
  Medico? _medicoSeleccionado;
  BloqueHorario? _bloqueSeleccionado;
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFin;
  
  bool _isLoadingMedicos = true;
  bool _isLoadingBloques = false;
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
    print("🔍 Cargando bloques horarios para médico: ${medico.id} - ${medico.nombreCompleto}");
    try {
      setState(() {
        _isLoadingBloques = true;
        _bloquesDisponibles = [];
        _bloqueSeleccionado = null;
        _fechaSeleccionada = null;
        _horaInicio = null;
        _horaFin = null;
      });
      
      // Obtener token para autenticación
      final token = await storage.read(key: "token") ?? "";
      print("🔍 Token: ${token.isNotEmpty ? 'Presente' : 'Ausente'}");
      
      final bloques = await CitaService.getBloquesHorarioMedico(medico.id, token);
      print("🔍 Bloques horarios obtenidos: ${bloques.length}");
      for (var bloque in bloques) {
        print("🔍 Bloque: ${bloque.diaSemanaDisplay} - ${bloque.horarioDisplay}");
      }
      
      setState(() {
        _bloquesDisponibles = bloques;
        _isLoadingBloques = false;
      });
    } catch (e) {
      print("❌ Error al cargar bloques horarios: $e");
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
        _horaInicio = null;
        _horaFin = null;
      });
    }
  }

  List<TimeOfDay> _generarHorasValidas() {
    if (_bloqueSeleccionado == null) return [];
    
    final bloque = _bloqueSeleccionado!;
    final List<TimeOfDay> horasValidas = [];
    
    // Convertir DateTime a TimeOfDay para facilitar el cálculo
    final inicioBloque = TimeOfDay(
      hour: bloque.horaInicio.hour, 
      minute: bloque.horaInicio.minute
    );
    final finBloque = TimeOfDay(
      hour: bloque.horaFin.hour, 
      minute: bloque.horaFin.minute
    );
    
    // Calcular intervalos válidos
    int minutoActual = inicioBloque.hour * 60 + inicioBloque.minute;
    final minutoFinal = finBloque.hour * 60 + finBloque.minute;
    
    while (minutoActual < minutoFinal) {
      final hora = minutoActual ~/ 60;
      final minuto = minutoActual % 60;
      
      // Verificar que no excedamos las 24 horas
      if (hora < 24) {
        horasValidas.add(TimeOfDay(hour: hora, minute: minuto));
      }
      
      minutoActual += bloque.duracionCitaMinutos;
    }
    
    return horasValidas;
  }

  Future<List<TimeOfDay>> _obtenerHorasDisponibles() async {
    if (_bloqueSeleccionado == null || _fechaSeleccionada == null) {
      return [];
    }

    try {
      final todasLasHoras = _generarHorasValidas();
      final fechaString = _fechaSeleccionada!.toIso8601String().split('T')[0];
      final horasOcupadas = await CitaService.getHorasOcupadas(_bloqueSeleccionado!.id, fechaString);
      
      // Filtrar las horas ocupadas
      final horasDisponibles = todasLasHoras.where((hora) {
        final horaString = '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
        return !horasOcupadas.contains(horaString);
      }).toList();
      
      return horasDisponibles;
    } catch (e) {
      print("❌ Error al obtener horas disponibles: $e");
      return _generarHorasValidas(); // Fallback a todas las horas válidas
    }
  }

  Future<void> _seleccionarHoraInicio() async {
    // Mostrar loading mientras obtenemos las horas disponibles
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final horasDisponibles = await _obtenerHorasDisponibles();
      
      // Cerrar el loading
      if (mounted) Navigator.of(context).pop();
      
      if (horasDisponibles.isEmpty) {
        _mostrarError('No hay horas disponibles para la fecha seleccionada');
        return;
      }

      final picked = await showDialog<TimeOfDay>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Seleccionar Hora de Inicio'),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: horasDisponibles.length,
              itemBuilder: (context, index) {
                final hora = horasDisponibles[index];
                return ListTile(
                  title: Text(hora.format(context)),
                  subtitle: Text('Duración: ${_bloqueSeleccionado!.duracionCitaMinutos} minutos'),
                  onTap: () => Navigator.of(context).pop(hora),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      );
      
      if (picked != null) {
        setState(() {
          _horaInicio = picked;
          // Calcular automáticamente la hora de fin basada en la duración
          final duracion = _bloqueSeleccionado!.duracionCitaMinutos;
          final totalMinutos = picked.hour * 60 + picked.minute + duracion;
          _horaFin = TimeOfDay(
            hour: totalMinutos ~/ 60,
            minute: totalMinutos % 60,
          );
        });
      }
    } catch (e) {
      // Cerrar el loading si está abierto
      if (mounted) Navigator.of(context).pop();
      
      // Limpiar horas si hay error
      setState(() {
        _horaInicio = null;
        _horaFin = null;
      });
      
      _mostrarError('Error al cargar horas disponibles: $e');
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
    
    if (_horaInicio == null) {
      _mostrarError('Por favor selecciona la hora de inicio');
      return;
    }
    
    if (_horaFin == null) {
      _mostrarError('Por favor selecciona la hora de fin');
      return;
    }

    setState(() => _isCreating = true);

    try {
      // Validaciones adicionales justo antes de usar los valores
      if (_horaInicio == null) {
        throw Exception('Hora de inicio no seleccionada');
      }
      
      if (_horaFin == null || _bloqueSeleccionado == null) {
        // Recalcular hora de fin si es null
        print("⚠️ [Frontend] Recalculando hora de fin...");
        final duracion = _bloqueSeleccionado!.duracionCitaMinutos;
        final totalMinutos = _horaInicio!.hour * 60 + _horaInicio!.minute + duracion;
        _horaFin = TimeOfDay(
          hour: totalMinutos ~/ 60,
          minute: totalMinutos % 60,
        );
        
        if (_horaFin == null) {
          throw Exception('No se pudo calcular la hora de fin');
        }
      }
      
      // Obtener el ID del paciente del usuario actual
      final pacienteId = await CitaService.getMiPacienteId();
      // Convertir TimeOfDay a string HH:MM con validación
      final horaInicioStr = '${_horaInicio!.hour.toString().padLeft(2, '0')}:${_horaInicio!.minute.toString().padLeft(2, '0')}';
      final horaFinStr = '${_horaFin!.hour.toString().padLeft(2, '0')}:${_horaFin!.minute.toString().padLeft(2, '0')}';
      final notasText = _notasController.text.trim();
      // Formatear fecha de manera más robusta
      final fechaStr = '${_fechaSeleccionada!.year.toString().padLeft(4, '0')}-${_fechaSeleccionada!.month.toString().padLeft(2, '0')}-${_fechaSeleccionada!.day.toString().padLeft(2, '0')}';
      print("🔍 [Frontend] Preparando datos para envío:");
      print("🔍 [Frontend] - Fecha: $fechaStr");
      print("🔍 [Frontend] - Hora inicio: $horaInicioStr");
      print("🔍 [Frontend] - Hora fin: $horaFinStr");
      print("🔍 [Frontend] - Notas: '$notasText'");
      print("🔍 [Frontend] - Bloque horario ID: ${_bloqueSeleccionado!.id}");
      final data = <String, dynamic>{
        'fecha': fechaStr,
        'hora_inicio': horaInicioStr,
        'hora_fin': horaFinStr,
        'notas': notasText.isEmpty ? '' : notasText,  // Siempre string, nunca null
        'bloque_horario': _bloqueSeleccionado!.id,
        'paciente': pacienteId,
        'tipo': 'CONSULTA', // O el valor que corresponda
      };

      print("🔍 [Frontend] Enviando datos de cita: $data");
      print("🔍 [Frontend] Paciente ID obtenido: $pacienteId");

      final citaCreada = await CitaService.crearCita(data);
      print("🔍 [Frontend] Cita creada exitosamente: \\${citaCreada.id}");


      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cita creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Retorna true para indicar que se creó
      }
    } catch (e, stackTrace) {
      print("❌ [Frontend] Error completo en _crearCita: $e");
      print("❌ [Frontend] Stack trace: $stackTrace");
      print("❌ [Frontend] Tipo de error: ${e.runtimeType}");
      
      if (mounted) {
        String errorMessage = 'Error al crear la cita';
        
        // Extraer mensaje específico del error
        if (e.toString().contains('ya se encuentra ocupado')) {
          errorMessage = 'El horario seleccionado ya está ocupado. Por favor selecciona otra hora.';
        } else if (e.toString().contains('400')) {
          errorMessage = 'Error en los datos enviados. Verifica la información.';
        } else if (e.toString().contains('TypeError') || e.toString().contains('Null')) {
          errorMessage = 'Error interno de la aplicación. Por favor intenta nuevamente.';
        } else {
          errorMessage = 'Error al crear la cita: $e';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
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

Future<void> _makePayment() async {
    try {
      // 1️⃣ Llamar a tu backend para crear PaymentIntent
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/citas_pagos/create-payment-intent/'), // Android emulator
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'amount': 1000, 'currency': 'usd'}), // $10.00
      );

      final jsonResponse = json.decode(response.body);
      final clientSecret = jsonResponse['clientSecret'];

      // 2️⃣ Inicializar el pago en Stripe
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Mi Tienda Flutter',
          style: ThemeMode.light,
        ),
      );

      // 3️⃣ Mostrar la hoja de pago nativa
      await Stripe.instance.presentPaymentSheet();

      print('✅ Pago completado con éxito');
    } catch (e) {
      print('❌ Error en el pago: $e');
    }
  }

  // Esta es la nueva función que tu botón debe llamar
Future<void> _iniciarCreacionYPagoDeCita() async {
  // =======================================================================
  // PASO 1: VALIDACIÓN (Copiado directamente de tu función _crearCita)
  // =======================================================================
  if (!_formKey.currentState!.validate()) return;
  
  if (_medicoSeleccionado == null || _bloqueSeleccionado == null || _fechaSeleccionada == null || _horaInicio == null) {
    _mostrarError('Por favor, completa todos los campos requeridos.');
    return;
  }

  setState(() => _isCreating = true);

  try {
    // =======================================================================
    // PASO 2: PREPARACIÓN DE DATOS (Copiado de tu función _crearCita)
    // =======================================================================
    
    // Recalcular hora de fin para asegurar que no sea nula
    final duracion = _bloqueSeleccionado!.duracionCitaMinutos;
    final totalMinutos = _horaInicio!.hour * 60 + _horaInicio!.minute + duracion;
    final horaFinCalculada = TimeOfDay(
      hour: totalMinutos ~/ 60,
      minute: totalMinutos % 60,
    );
    
    // Formatear todos los datos para enviar al backend
    final fechaStr = '${_fechaSeleccionada!.year.toString().padLeft(4, '0')}-${_fechaSeleccionada!.month.toString().padLeft(2, '0')}-${_fechaSeleccionada!.day.toString().padLeft(2, '0')}';
    final horaInicioStr = '${_horaInicio!.hour.toString().padLeft(2, '0')}:${_horaInicio!.minute.toString().padLeft(2, '0')}';
    final horaFinStr = '${horaFinCalculada.hour.toString().padLeft(2, '0')}:${horaFinCalculada.minute.toString().padLeft(2, '0')}';
    final notasText = _notasController.text.trim();

    // Obtener el ID del paciente del usuario actual
    final pacienteId = await CitaService.getMiPacienteId();
    // Este es el objeto que enviaremos al backend
    final datosCita = <String, dynamic>{
      'fecha': fechaStr,
      'hora_inicio': horaInicioStr,
      'hora_fin': horaFinStr,
      'notas': notasText.isEmpty ? '' : notasText,
      'bloque_horario': _bloqueSeleccionado!.id,
      'paciente': pacienteId,
      'tipo': 'CONSULTA', // O el valor que corresponda
    };
    
    print("🔍 [Frontend] Datos validados. Iniciando proceso de pago...");
    print("🔍 [Frontend] Datos a enviar: $datosCita");

    // =======================================================================
    // PASO 3: INICIAR EL PAGO (Lógica de _makePayment, ahora con datos reales)
    // =======================================================================
    
    // 1️⃣ Llamar a tu backend para crear la pre-reserva y el PaymentIntent
    final response = await http.post(
        Uri.parse('https://clinica-backend-b8m9.onrender.com/api/citas_pagos/create-payment-intent/'), // Android emulator
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'amount': 1000, 'currency': 'usd'}), // $10.00
      ); // Asumiendo que tienes un CitaService
    
    final jsonResponse = json.decode(response.body);
    
    if (response.statusCode != 200) {
      // Si el backend devuelve un error (ej: horario ya ocupado), lo mostramos
      throw Exception(jsonResponse['error'] ?? 'Error del servidor al iniciar el pago.');
    }
    
    final clientSecret = jsonResponse['clientSecret'];
    final citaId = jsonResponse['citaId']; // El ID de la cita pre-reservada

    // 2️⃣ Inicializar y mostrar la hoja de pago de Stripe
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Tu Clínica', // Personaliza el nombre
      ),
    );
    await Stripe.instance.presentPaymentSheet();

    // 3️⃣ Si el pago fue exitoso, ahora creamos la cita en el backend
    final citaCreada = await CitaService.crearCita(datosCita);
    print("✅ [Frontend] Pago completado y cita creada (ID: ${citaCreada.id})");

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cita creada y pagada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Retorna true para indicar éxito
    }

  } catch (e, stackTrace) {
    // =======================================================================
    // PASO 4: MANEJO DE ERRORES (Combinando la lógica de ambas funciones)
    // =======================================================================
    print("❌ [Frontend] Error en el flujo de creación/pago: $e");
    print("❌ [Frontend] Stack trace: $stackTrace");

    if (mounted) {
      String errorMessage = 'Ocurrió un error';
      if (e is StripeException) {
        // El error viene de Stripe (ej: tarjeta rechazada, usuario cancela)
        errorMessage = 'Error en el pago: ${e.error.localizedMessage}';
      } else {
        // Error de validación del backend o de red
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }
      _mostrarError(errorMessage);
    }
  } finally {
    setState(() => _isCreating = false);
  }
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
                                        mainAxisSize: MainAxisSize.min,
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
                                      _horaInicio = null;
                                      _horaFin = null;
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

                      // Selector de hora de inicio
                      Text(
                        'Hora de Inicio *',
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
                          onPressed: _fechaSeleccionada == null || _bloqueSeleccionado == null ? null : _seleccionarHoraInicio,
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(Icons.access_time, size: 20),
                          label: Text(
                            _horaInicio == null
                                ? (_fechaSeleccionada == null 
                                    ? 'Primero selecciona una fecha'
                                    : 'Seleccionar hora de inicio')
                                : '${_horaInicio!.hour.toString().padLeft(2, '0')}:${_horaInicio!.minute.toString().padLeft(2, '0')}',
                            style: GoogleFonts.roboto(),
                          ),
                        ),
                      ),

                      SizedBox(height: 24),

                      // Selector de hora de fin
                      Text(
                        'Hora de Fin *',
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
                          onPressed: null, // Deshabilitado porque se calcula automáticamente
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(Icons.access_time, size: 20),
                          label: Text(
                            _horaFin == null
                                ? 'Hora de fin (se calcula automáticamente)'
                                : '${_horaFin!.hour.toString().padLeft(2, '0')}:${_horaFin!.minute.toString().padLeft(2, '0')} (Calculado automáticamente)',
                            style: GoogleFonts.roboto(),
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
                        onPressed: _isCreating ? null : _iniciarCreacionYPagoDeCita,
                        // onPressed: _isCreating ? null : _crearCita,
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