import 'package:flutter/material.dart';
import '../../data/services/PatologiaService.dart';

class CreatePatologia extends StatefulWidget {
  const CreatePatologia({super.key});

  @override
  State<CreatePatologia> createState() => _CreatePatologiaState();
}

class _CreatePatologiaState extends State<CreatePatologia> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _aliasController = TextEditingController();
  final _descripcionController = TextEditingController();
  String _gravedadSeleccionada = 'LEVE';

  final List<String> _opcionesGravedad = [
    'LEVE',
    'MODERADO',
    'GRAVE',
    'CRITICA',
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _aliasController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Patología')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _aliasController,
                decoration: const InputDecoration(
                  labelText: 'Alias',
                  border: OutlineInputBorder(),
                ),
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Por favor ingresa el alias';
                //   }
                //   return null;
                // },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Por favor ingresa la descripción';
                //   }
                //   return null;
                // },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gravedadSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Gravedad',
                  border: OutlineInputBorder(),
                ),
                items:
                    _opcionesGravedad.map((String gravedad) {
                      return DropdownMenuItem<String>(
                        value: gravedad,
                        child: Text(gravedad),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _gravedadSeleccionada = newValue!;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _crearPatologia,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Crear Patología'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _crearPatologia() async {
    if (!_formKey.currentState!.validate()) return;

    final nuevaPatologia = {
      "nombre": _nombreController.text.trim(),
      "alias": _aliasController.text.trim(),
      "descripcion": _descripcionController.text.trim(),
      "gravedad": _gravedadSeleccionada,
    };

    try {
      await PatologiaService.createPatologia(nuevaPatologia);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patología creada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
