import 'package:flutter/material.dart';
import '../../data/models/paciente.dart';
import '../../data/services/PacienteService.dart';

class CrearPacienteScreen extends StatefulWidget {
  const CrearPacienteScreen({super.key});

  @override
  State<CrearPacienteScreen> createState() => _CrearPacienteScreenState();
}

class _CrearPacienteScreenState extends State<CrearPacienteScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _hcController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _alergiasController = TextEditingController();
  final _antecedentesController = TextEditingController();

  DateTime? _fechaNacimiento;

  @override
  void dispose() {
    _hcController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _alergiasController.dispose();
    _antecedentesController.dispose();
    super.dispose();
  }

  Future<void> _pickFechaNacimiento() async {
    final now = DateTime.now();
    final ini = DateTime(now.year - 30, now.month, now.day);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? ini,
      firstDate: DateTime(1900, 1, 1),
      lastDate: now,
      helpText: 'Seleccionar fecha de nacimiento',
      locale: const Locale('es', 'BO'),
    );
    if (picked != null) {
      setState(() => _fechaNacimiento = picked);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final nuevo = Paciente(
      id: 0, // lo asigna el backend
      numeroHistoriaClinica: _hcController.text.trim(),
      nombre: _nombreController.text.trim(),
      apellido: _apellidoController.text.trim(),
      fechaNacimiento: _fechaNacimiento,             // null permitido
      alergias: _alergiasController.text.trim().isEmpty
          ? null
          : _alergiasController.text.trim(),
      antecedentesOculares: _antecedentesController.text.trim().isEmpty
          ? null
          : _antecedentesController.text.trim(),
      estado: true,
      fechaCreacion: DateTime.now(),                 // si tu modelo requiere, mándalo
      fechaModificacion: DateTime.now(),
      examenes: const [],                            // no se crean aquí
    );

    await PacienteService.createPaciente(nuevo);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final fechaLabel = _fechaNacimiento == null
        ? 'Seleccionar fecha'
        : '${_fechaNacimiento!.year}-${_fechaNacimiento!.month.toString().padLeft(2, '0')}-${_fechaNacimiento!.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Paciente')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _hcController,
                decoration: const InputDecoration(labelText: 'Historia clínica'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _apellidoController,
                decoration: const InputDecoration(labelText: 'Apellido'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text('Fecha de nacimiento: $fechaLabel'),
                  ),
                  TextButton.icon(
                    onPressed: _pickFechaNacimiento,
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Elegir'),
                  ),
                ],
              ),
              TextFormField(
                controller: _alergiasController,
                decoration: const InputDecoration(labelText: 'Alergias (opcional)'),
                maxLines: 2,
              ),
              TextFormField(
                controller: _antecedentesController,
                decoration:
                    const InputDecoration(labelText: 'Antecedentes oculares (opcional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _guardar,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
