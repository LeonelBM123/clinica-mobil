import 'package:flutter/material.dart';
import '../../data/services/MedicoService.dart';

class NuevoMedicoScreen extends StatefulWidget {
  const NuevoMedicoScreen({super.key});

  @override
  State<NuevoMedicoScreen> createState() => _NuevoMedicoScreenState();
}

class _NuevoMedicoScreenState extends State<NuevoMedicoScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> nuevoMedico = {
    "nombre_usuario": "",
    "correo_usuario": "",
    "password_usuario": "",
    "sexo_usuario": "",
    "fecha_nacimiento_usuario": "",
    "telefono_usuario": "",
    "direccion_usuario": "",
    "numero_colegiado": "",
    "especialidades": <int>[],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Médico')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre'),
                onSaved: (val) => nuevoMedico['nombre_usuario'] = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Correo'),
                onSaved: (val) => nuevoMedico['correo_usuario'] = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onSaved: (val) => nuevoMedico['password_usuario'] = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Sexo (M/F)'),
                onSaved: (val) => nuevoMedico['sexo_usuario'] = val,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Fecha de nacimiento (YYYY-MM-DD)',
                ),
                onSaved: (val) => nuevoMedico['fecha_nacimiento_usuario'] = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Teléfono'),
                onSaved: (val) => nuevoMedico['telefono_usuario'] = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Dirección'),
                onSaved: (val) => nuevoMedico['direccion_usuario'] = val,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Número colegiado',
                ),
                onSaved: (val) => nuevoMedico['numero_colegiado'] = val,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Especialidades (IDs separados por coma)',
                  hintText: 'Ej: 1,2,5 (dejar vacío si no tiene)',
                ),
                onSaved: (val) {
                  if (val == null || val.trim().isEmpty) {
                    nuevoMedico['especialidades'] =
                        <int>[]; // lista vacía si no hay nada
                  } else {
                    nuevoMedico['especialidades'] =
                        val
                            .split(',')
                            .map((e) => int.tryParse(e.trim()) ?? 0)
                            .where(
                              (id) => id != 0,
                            ) // descartamos ceros inválidos
                            .toList();
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Guardar'),
                onPressed: () async {
                  _formKey.currentState?.save();

                  // Validación mínima: campos obligatorios
                  if (nuevoMedico['nombre_usuario'] == "" ||
                      nuevoMedico['correo_usuario'] == "" ||
                      nuevoMedico['password_usuario'] == "" ||
                      nuevoMedico['numero_colegiado'] == "") {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Completa los campos obligatorios'),
                      ),
                    );
                    return;
                  }

                  try {
                    await MedicoService.createMedico(nuevoMedico);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Médico creado correctamente'),
                      ),
                    );
                    Navigator.pop(context, true); // true para refrescar lista
                  } catch (e) {
                    print('Error creando médico: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error creando médico')),
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
