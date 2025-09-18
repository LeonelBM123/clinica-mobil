import 'package:flutter/material.dart';
import '../../data/services/PatologiaService.dart';
import '../../data/models/patologia.dart';

class EditPatologia extends StatefulWidget {
  final Patologia patologia;
  const EditPatologia({super.key, required this.patologia});

  @override
  State<EditPatologia> createState() => _EditPatologiaState();
}

class _EditPatologiaState extends State<EditPatologia> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nombreController;
  late TextEditingController aliasController;
  late TextEditingController descripcionController;
  late String gravedadSeleccionada;

  final List<String> opcionesGravedad = ['LEVE', 'MODERADA', 'GRAVE'];

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.patologia.nombre);
    aliasController = TextEditingController(text: widget.patologia.alias);
    descripcionController = TextEditingController(
      text: widget.patologia.descripcion,
    );

    // Si el valor no está en la lista, usa el primero
    gravedadSeleccionada =
        opcionesGravedad.contains(widget.patologia.gravedad)
            ? widget.patologia.gravedad
            : opcionesGravedad.first;
  }

  @override
  void dispose() {
    nombreController.dispose();
    aliasController.dispose();
    descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Patología')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nombreController,
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
                controller: aliasController,
                decoration: const InputDecoration(
                  labelText: 'Alias',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: gravedadSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Gravedad',
                  border: OutlineInputBorder(),
                ),
                items:
                    opcionesGravedad.map((String gravedad) {
                      return DropdownMenuItem<String>(
                        value: gravedad,
                        child: Text(gravedad),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    gravedadSeleccionada = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor selecciona la gravedad';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _actualizarPatologia,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Actualizar Patología'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _actualizarPatologia() async {
    if (!_formKey.currentState!.validate()) return;

    final datosActualizados = {
      "nombre": nombreController.text.trim(),
      "alias": aliasController.text.trim(),
      "descripcion": descripcionController.text.trim(),
      "gravedad": gravedadSeleccionada,
    };

    try {
      await PatologiaService.updatePatologia(
        widget.patologia.id,
        datosActualizados,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patología actualizada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // true para refrescar lista
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
