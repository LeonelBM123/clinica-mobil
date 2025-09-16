import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../data/services/MedicoService.dart';
import '../data/models/medico.dart';
import 'EditarMedicoScreen.dart';
import 'NuevoMedicoScreen.dart';

class GestionarMedicoScreen extends StatefulWidget {
  const GestionarMedicoScreen({super.key});

  @override
  State<GestionarMedicoScreen> createState() => _GestionarMedicoScreenState();
}

class _GestionarMedicoScreenState extends State<GestionarMedicoScreen> {
  List<Medico> medicos = [];
  bool cargando = false;

  @override
  void initState() {
    super.initState();
    cargarMedicos();
  }

  Future<void> cargarMedicos() async {
    setState(() => cargando = true);

    try {
      final data = await MedicoService.getMedicos();
      if (!mounted) return;
      setState(() => medicos = data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error cargando médicos')));
    } finally {
      if (!mounted) return;
      setState(() => cargando = false);
    }
  }

  void eliminarMedicoLocal(int id) {
    setState(() {
      medicos.removeWhere((m) => m.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text('Gestionar Médicos')),
          body: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: medicos.length,
            itemBuilder: (context, index) {
              final medico = medicos[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ExpansionTile(
                  leading: FaIcon(
                    FontAwesomeIcons.userDoctor,
                    size: 40,
                    color: Colors.blue, // Opcional: color médico
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ID: ${medico.id}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Nombre: ${medico.nombre}'),
                            Text('N° Colegiado: ${medico.numeroColegiado}'),
                            Text(
                              'Especialidades: ${medico.especialidades.length}',
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          EditarMedicoScreen(medico: medico),
                                ),
                              );
                              cargarMedicos();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirmado = await showDialog<bool>(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text('¿Estás seguro?'),
                                      content: const Text(
                                        'Esta acción eliminará al médico.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: const Text('No'),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, true),
                                          child: const Text('Sí'),
                                        ),
                                      ],
                                    ),
                              );

                              if (confirmado ?? false) {
                                try {
                                  await MedicoService.deleteMedico(medico.id);
                                  eliminarMedicoLocal(medico.id);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Error al eliminar médico'),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Correo: ${medico.correo}'),
                          Text('Sexo: ${medico.sexo}'),
                          Text('Fecha Nacimiento: ${medico.fechaNacimiento}'),
                          Text('Teléfono: ${medico.telefono}'),
                          Text('Dirección: ${medico.direccion}'),
                          Text('Rol: ${medico.rol}'),
                          Text(
                            'Especialidades: ${medico.especialidades.join(', ')}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NuevoMedicoScreen(),
                ),
              );
              cargarMedicos();
            },
          ),
        ),
        // --- Overlay loader ---
        if (cargando)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }
}
