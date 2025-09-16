import 'package:flutter/material.dart';
import '../data/services/MedicoService.dart';
import '../data/models/medico.dart';

class EditarMedicoScreen extends StatefulWidget {
  final Medico medico;
  const EditarMedicoScreen({super.key, required this.medico});

  @override
  State<EditarMedicoScreen> createState() => _EditarMedicoScreenState();
}

class _EditarMedicoScreenState extends State<EditarMedicoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController numeroColegiadoController;
  late TextEditingController especialidadesController; // IDs separados por coma

  @override
  void initState() {
    super.initState();
    numeroColegiadoController = TextEditingController(
      text: widget.medico.numeroColegiado,
    );
    especialidadesController = TextEditingController(
      text: widget.medico.especialidadesIds.join(
        ',',
      ), // mostramos los IDs actuales
    );
  }

  @override
  void dispose() {
    numeroColegiadoController.dispose();
    especialidadesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Médico')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: numeroColegiadoController,
                decoration: const InputDecoration(
                  labelText: 'Número colegiado',
                ),
                validator: (val) {
                  if (val == null || val.isEmpty)
                    return 'Ingresa el número colegiado';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: especialidadesController,
                decoration: const InputDecoration(
                  labelText: 'Especialidades (IDs separados por coma)',
                ),
                validator: (val) {
                  if (val == null || val.isEmpty)
                    return 'Ingresa al menos una especialidad';
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                child: const Text('Guardar cambios'),
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  // Creamos el Map para PATCH
                  final medicoEditado = {
                    "numero_colegiado": numeroColegiadoController.text,
                    "especialidades":
                        especialidadesController.text
                            .split(',')
                            .map((e) => int.tryParse(e.trim()) ?? 0)
                            .where((id) => id != 0)
                            .toList(),
                  };

                  try {
                    await MedicoService.updateMedico(
                      widget.medico.id,
                      medicoEditado,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Médico actualizado')),
                    );
                    Navigator.pop(
                      context,
                      true,
                    ); // retornamos true para recargar la lista
                  } catch (e) {
                    print(e);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error al actualizar médico'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
