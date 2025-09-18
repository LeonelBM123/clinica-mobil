import 'package:flutter/material.dart';
import '../../data/models/paciente.dart';
import '../../data/services/PacienteService.dart';

class EditarPacienteScreen extends StatefulWidget {
  final Paciente paciente;

  const EditarPacienteScreen({super.key, required this.paciente});

  @override
  State<EditarPacienteScreen> createState() => _EditarPacienteScreenState();
}

class _EditarPacienteScreenState extends State<EditarPacienteScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _hcController;
  late final TextEditingController _nombreController;
  late final TextEditingController _apellidoController;
  late final TextEditingController _alergiasController;
  late final TextEditingController _antecedentesController;

  DateTime? _fechaNacimiento;

  @override
  void initState() {
    super.initState();
    final p = widget.paciente;
    _hcController = TextEditingController(text: p.numeroHistoriaClinica);
    _nombreController = TextEditingController(text: p.nombre);
    _apellidoController = TextEditingController(text: p.apellido);
    _alergiasController = TextEditingController(text: p.alergias ?? '');
    _antecedentesController =
        TextEditingController(text: p.antecedentesOculares ?? '');
    _fechaNacimiento = p.fechaNacimiento; // puede ser null
  }

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
    final initial = _fechaNacimiento ?? DateTime(now.year - 30, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
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

    final p = widget.paciente;

    final actualizado = Paciente(
      id: p.id,
      numeroHistoriaClinica: _hcController.text.trim(),
      nombre: _nombreController.text.trim(),
      apellido: _apellidoController.text.trim(),
      fechaNacimiento: _fechaNacimiento, // null permitido
      alergias: _alergiasController.text.trim().isEmpty
          ? null
          : _alergiasController.text.trim(),
      antecedentesOculares: _antecedentesController.text.trim().isEmpty
          ? null
          : _antecedentesController.text.trim(),
      estado: p.estado,                         // preservamos
      fechaCreacion: p.fechaCreacion,           // lo maneja el backend
      fechaModificacion: DateTime.now(),        // toca a nosotros actualizarlo
      examenes: p.examenes,                     // no editamos aquí
    );

    await PacienteService.updatePaciente(p.id, actualizado);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final fechaLabel = _fechaNacimiento == null
        ? 'Seleccionar fecha'
        : '${_fechaNacimiento!.year}-${_fechaNacimiento!.month.toString().padLeft(2, '0')}-${_fechaNacimiento!.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: const Text("Editar Paciente")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _hcController,
                decoration: const InputDecoration(labelText: "Historia clínica"),
                validator: (v) => v == null || v.trim().isEmpty ? "Requerido" : null,
              ),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: "Nombre"),
                validator: (v) => v == null || v.trim().isEmpty ? "Requerido" : null,
              ),
              TextFormField(
                controller: _apellidoController,
                decoration: const InputDecoration(labelText: "Apellido"),
                validator: (v) => v == null || v.trim().isEmpty ? "Requerido" : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: Text('Fecha de nacimiento: $fechaLabel')),
                  TextButton.icon(
                    onPressed: _pickFechaNacimiento,
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Elegir'),
                  ),
                ],
              ),
              TextFormField(
                controller: _alergiasController,
                decoration: const InputDecoration(labelText: "Alergias (opcional)"),
                maxLines: 2,
              ),
              TextFormField(
                controller: _antecedentesController,
                decoration: const InputDecoration(labelText: "Antecedentes oculares (opcional)"),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _guardar,
                child: const Text("Guardar cambios"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
