import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/models.dart';
import '../../data/services/MedicoService.dart';
import '../../data/services/EspecialidadService.dart';
import '../../data/services/UsuarioService.dart';

class EditarMedicoScreen extends StatefulWidget {
  final Medico medico;

  const EditarMedicoScreen({super.key, required this.medico});

  @override
  State<EditarMedicoScreen> createState() => _EditarMedicoScreenState();
}

class _EditarMedicoScreenState extends State<EditarMedicoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _correoController;
  late final TextEditingController _telefonoController;
  late final TextEditingController _direccionController;
  late final TextEditingController _numeroColegiado;
  DateTime? _fechaNacimiento;
  String _sexo = 'M';
  List<Especialidad> _especialidadesSeleccionadas = [];
  List<Especialidad> _especialidadesDisponibles = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _inicializarControladores();
    _cargarEspecialidades();
  }

  void _inicializarControladores() {
    _nombreController = TextEditingController(text: widget.medico.nombre);
    _correoController = TextEditingController(text: widget.medico.correo);
    _telefonoController = TextEditingController(text: widget.medico.telefono ?? '');
    _direccionController = TextEditingController(text: widget.medico.direccion ?? '');
    _numeroColegiado = TextEditingController(text: widget.medico.numeroColegiado);
    _fechaNacimiento = widget.medico.fechaNacimiento;
    _sexo = widget.medico.sexo;
    _especialidadesSeleccionadas = List.from(widget.medico.especialidades);
  }

  void _cargarEspecialidades() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final especialidades = await EspecialidadService.getEspecialidades();
      
      if (mounted) {
        setState(() {
          _especialidadesDisponibles = especialidades;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        /*setState(() {
          _isLoading = false;
          // En caso de error, usar especialidades por defecto
          _especialidadesDisponibles = [
            Especialidad(id: 1, nombre: 'Oftalmología'),
            Especialidad(id: 2, nombre: 'Neurología'),
            Especialidad(id: 3, nombre: 'Cardiología'),
            Especialidad(id: 4, nombre: 'Pediatría'),
            Especialidad(id: 5, nombre: 'Medicina General'),
          ];
        });
        */
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar especialidades: $e'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Reintentar',
              onPressed: _cargarEspecialidades,
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _numeroColegiado.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime(1980),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
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
    if (picked != null && picked != _fechaNacimiento) {
      setState(() {
        _fechaNacimiento = picked;
      });
    }
  }

  Future<void> _actualizarMedico() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaNacimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona la fecha de nacimiento'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Primero actualizar los datos del usuario (información personal y contacto)
      final usuarioData = {
        'nombre': _nombreController.text.trim(),
        'correo': _correoController.text.trim(),
        'sexo': _sexo,
        'fecha_nacimiento': _fechaNacimiento!.toIso8601String().split('T')[0],
        'telefono': _telefonoController.text.trim(),
        'direccion': _direccionController.text.trim(),
      };

      // Actualizar datos del usuario
      //await UsuarioService.updateUsuario(widget.medico.medico.id, usuarioData);

      // 2. Luego actualizar los datos específicos del médico
      final medicoData = {
        'numero_colegiado': _numeroColegiado.text.trim(),
        'especialidades': _especialidadesSeleccionadas.map((e) => e.id).toList(),
      };

      await MedicoService.updateMedico(widget.medico.id, medicoData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Médico actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error al actualizar médico: $e';
        
        // Mensajes más específicos según el tipo de error
        if (e.toString().contains('usuario')) {
          errorMessage = 'Error al actualizar información personal: $e';
        } else if (e.toString().contains('medico') || e.toString().contains('especialidad')) {
          errorMessage = 'Error al actualizar información profesional: $e';
        } else if (e.toString().contains('401') || e.toString().contains('autorizado')) {
          errorMessage = 'No tienes permisos para realizar esta acción. Inicia sesión nuevamente.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _mostrarSelectorEspecialidades() {
    if (_especialidadesDisponibles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cargando especialidades, por favor espera...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF17635F),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Seleccionar Especialidades',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _especialidadesDisponibles.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Cargando especialidades...'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: _especialidadesDisponibles.length,
                        itemBuilder: (context, index) {
                          final especialidad = _especialidadesDisponibles[index];
                          final isSelected = _especialidadesSeleccionadas
                              .any((e) => e.id == especialidad.id);

                          return CheckboxListTile(
                            title: Text(especialidad.nombre),
                            value: isSelected,
                            activeColor: const Color(0xFF17635F),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _especialidadesSeleccionadas.add(especialidad);
                                } else {
                                  _especialidadesSeleccionadas
                                      .removeWhere((e) => e.id == especialidad.id);
                                }
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Editar Médico',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF17635F),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header con información actual
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFF17635F),
                      child: Text(
                        widget.medico.nombre.isNotEmpty 
                            ? widget.medico.nombre[0].toUpperCase()
                            : 'M',
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.medico.nombreCompleto,
                            style: GoogleFonts.roboto(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            'Colegiado: ${widget.medico.numeroColegiado}',
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
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Información Personal
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información Personal (Usuario)',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF17635F),
                      ),
                    ),
                    Text(
                      'Estos datos se actualizan en el perfil del usuario',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre Completo',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _correoController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Correo Electrónico',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El correo es requerido';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Ingresa un correo válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _sexo,
                            decoration: InputDecoration(
                              labelText: 'Sexo',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'M', child: Text('Masculino')),
                              DropdownMenuItem(value: 'F', child: Text('Femenino')),
                            ],
                            onChanged: (value) => setState(() => _sexo = value!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: InkWell(
                            onTap: _seleccionarFecha,
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Fecha de Nacimiento',
                                prefixIcon: const Icon(Icons.calendar_today),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                _fechaNacimiento != null
                                    ? '${_fechaNacimiento!.day}/${_fechaNacimiento!.month}/${_fechaNacimiento!.year}'
                                    : 'Seleccionar fecha',
                                style: TextStyle(
                                  color: _fechaNacimiento != null
                                      ? Colors.black87
                                      : Colors.grey[600],
                                ),
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
            
            const SizedBox(height: 16),
            
            // Información de Contacto
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información de Contacto (Usuario)',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF17635F),
                      ),
                    ),
                    Text(
                      'Estos datos se actualizan en el perfil del usuario',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _telefonoController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Teléfono',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty && value.length < 8) {
                          return 'El teléfono debe tener al menos 8 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _direccionController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Dirección',
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Información Profesional
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información Profesional (Médico)',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF17635F),
                      ),
                    ),
                    Text(
                      'Datos específicos del médico',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _numeroColegiado,
                      decoration: InputDecoration(
                        labelText: 'Número de Colegiado',
                        prefixIcon: const Icon(Icons.badge),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El número de colegiado es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Especialidades
                    InkWell(
                      onTap: _especialidadesDisponibles.isEmpty 
                          ? null 
                          : _mostrarSelectorEspecialidades,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Especialidades',
                          prefixIcon: const Icon(Icons.medical_services),
                          suffixIcon: _especialidadesDisponibles.isEmpty
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.arrow_drop_down),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _especialidadesDisponibles.isEmpty
                              ? 'Cargando especialidades...'
                              : _especialidadesSeleccionadas.isEmpty
                                  ? 'Seleccionar especialidades'
                                  : _especialidadesSeleccionadas
                                      .map((e) => e.nombre)
                                      .join(', '),
                          style: TextStyle(
                            color: _especialidadesDisponibles.isEmpty
                                ? Colors.grey[600]
                                : _especialidadesSeleccionadas.isEmpty
                                    ? Colors.grey[600]
                                    : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF17635F)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: const Color(0xFF17635F),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _actualizarMedico,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF17635F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Guardar Cambios',
                            style: GoogleFonts.roboto(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}