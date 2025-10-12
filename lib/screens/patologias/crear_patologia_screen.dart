import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/services/PatologiaService.dart';

class CrearPatologiaScreen extends StatefulWidget {
  const CrearPatologiaScreen({super.key});

  @override
  State<CrearPatologiaScreen> createState() => _CrearPatologiaScreenState();
}

class _CrearPatologiaScreenState extends State<CrearPatologiaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _aliasController = TextEditingController();
  final _descripcionController = TextEditingController();
  String _gravedad = 'Leve';
  bool _isLoading = false;

  final List<String> _gravedadesDisponibles = [
    'Leve',
    'Moderada',
    'Grave',
    'Severa',
    'Crítica',
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _aliasController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _crearPatologia() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final patologiaData = {
        'nombre': _nombreController.text.trim(),
        'alias': _aliasController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'gravedad': _gravedad,
      };

      await PatologiaService.createPatologia(patologiaData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patología creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear patología: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _getGravedadColor(String gravedad) {
    switch (gravedad.toLowerCase()) {
      case 'leve':
        return Colors.green;
      case 'moderada':
        return Colors.orange;
      case 'grave':
        return Colors.red;
      case 'severa':
        return Colors.red[700]!;
      case 'crítica':
        return Colors.red[900]!;
      default:
        return Colors.blue;
    }
  }

  IconData _getGravedadIcon(String gravedad) {
    switch (gravedad.toLowerCase()) {
      case 'leve':
        return Icons.info_outline;
      case 'moderada':
        return Icons.warning_outlined;
      case 'grave':
        return Icons.error_outline;
      case 'severa':
        return Icons.dangerous_outlined;
      case 'crítica':
        return Icons.emergency;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Nueva Patología',
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
            // Información Básica
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF17635F).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.medical_services_outlined,
                            color: Color(0xFF17635F),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Información Básica',
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF17635F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre de la Patología',
                        prefixIcon: const Icon(Icons.local_hospital),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        helperText: 'Ej: Diabetes Mellitus Tipo 2',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre es requerido';
                        }
                        if (value.trim().length < 3) {
                          return 'El nombre debe tener al menos 3 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _aliasController,
                      decoration: InputDecoration(
                        labelText: 'Alias o Nombre Corto',
                        prefixIcon: const Icon(Icons.label_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        helperText: 'Ej: DM2, HTA, etc. (Opcional)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _descripcionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        prefixIcon: const Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        helperText: 'Descripción detallada de la patología',
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La descripción es requerida';
                        }
                        if (value.trim().length < 10) {
                          return 'La descripción debe ser más detallada';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Clasificación
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getGravedadColor(_gravedad).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getGravedadIcon(_gravedad),
                            color: _getGravedadColor(_gravedad),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Clasificación',
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF17635F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    DropdownButtonFormField<String>(
                      value: _gravedad,
                      decoration: InputDecoration(
                        labelText: 'Nivel de Gravedad',
                        prefixIcon: Icon(
                          _getGravedadIcon(_gravedad),
                          color: _getGravedadColor(_gravedad),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        helperText: 'Selecciona el nivel de gravedad apropiado',
                      ),
                      items: _gravedadesDisponibles.map((gravedad) {
                        return DropdownMenuItem(
                          value: gravedad,
                          child: Row(
                            children: [
                              Icon(
                                _getGravedadIcon(gravedad),
                                color: _getGravedadColor(gravedad),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                gravedad,
                                style: TextStyle(
                                  color: _getGravedadColor(gravedad),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _gravedad = value!;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Preview de la gravedad
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getGravedadColor(_gravedad).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getGravedadColor(_gravedad).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getGravedadIcon(_gravedad),
                            color: _getGravedadColor(_gravedad),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Gravedad: $_gravedad',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w500,
                              color: _getGravedadColor(_gravedad),
                            ),
                          ),
                        ],
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
                    onPressed: _isLoading ? null : _crearPatologia,
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
                            'Crear Patología',
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