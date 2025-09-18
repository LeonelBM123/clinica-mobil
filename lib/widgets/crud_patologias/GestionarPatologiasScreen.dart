import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../data/services/PatologiaService.dart';
import '../../data/models/patologia.dart';
import 'CreatePatologia.dart';
import 'EditPatologia.dart';

class GestionarPatologiaScreen extends StatefulWidget {
  const GestionarPatologiaScreen({super.key});

  @override
  State<GestionarPatologiaScreen> createState() =>
      _GestionarPatologiaScreenState();
}

class _GestionarPatologiaScreenState extends State<GestionarPatologiaScreen> {
  List<Patologia> patologias = [];
  bool cargando = false;

  @override
  void initState() {
    super.initState();
    cargarPatologia();
  }

  Future<void> cargarPatologia() async {
    setState(() => cargando = true);

    try {
      final data = await PatologiaService.getPatologias();
      if (!mounted) return;
      setState(() => patologias = data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error cargando patologías')),
      );
    } finally {
      if (!mounted) return;
      setState(() => cargando = false);
    }
  }

  void eliminarPatologiaLocal(int id) {
    setState(() {
      patologias.removeWhere((p) => p.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text('Gestionar Patologías')),
          body: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: patologias.length,
            itemBuilder: (context, index) {
              final patologia = patologias[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ExpansionTile(
                  leading: FaIcon(
                    FontAwesomeIcons.stethoscope,
                    size: 20,
                    color: const Color.fromARGB(
                      255,
                      3,
                      13,
                      28,
                    ), // Opcional: color médico
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ID: ${patologia.id}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Nombre: ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 16, // Ajusta según tu tema
                                    ),
                                  ),
                                  TextSpan(
                                    text: patologia.nombre,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color:
                                          Colors.black, // Ajusta según tu tema
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Alias: ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 16, // Ajusta según tu tema
                                    ),
                                  ),
                                  TextSpan(
                                    text: patologia.alias,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color:
                                          Colors.black, // Ajusta según tu tema
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Gravedad: ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 16, // Ajusta según tu tema
                                    ),
                                  ),
                                  TextSpan(
                                    text: patologia.gravedad,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color:
                                          Colors.black, // Ajusta según tu tema
                                    ),
                                  ),
                                ],
                              ),
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
                                          EditPatologia(patologia: patologia),
                                ),
                              );
                              cargarPatologia();
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
                                        'Esta acción eliminará la Patología.',
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
                                  await PatologiaService.deletePatologia(
                                    patologia.id,
                                  );
                                  eliminarPatologiaLocal(patologia.id);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Error al eliminar la Patología',
                                      ),
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
                          Text('Descripcion: ${patologia.descripcion}'),
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
                  builder: (context) => const CreatePatologia(),
                ),
              );
              cargarPatologia();
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
