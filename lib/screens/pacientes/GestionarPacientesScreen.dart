import 'package:flutter/material.dart';
import '../../data/models/paciente.dart';
import '../../data/services/PacienteService.dart';
import 'CrearPacienteScreen.dart';
import 'EditarPacienteScreen.dart';

class GestionarPacientesScreen extends StatefulWidget {
  const GestionarPacientesScreen({super.key});

  @override
  State<GestionarPacientesScreen> createState() => _GestionarPacientesScreenState();
}

class _GestionarPacientesScreenState extends State<GestionarPacientesScreen> {
  late Future<List<Paciente>> _futurePacientes;
  List<Paciente> _todos = [];
  List<Paciente> _filtrados = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futurePacientes = PacienteService.getPacientes().then((list) {
      _todos = list;
      _filtrados = list;
      return list;
    });
  }

  void _aplicarFiltro(String q) {
    q = q.toLowerCase().trim();
    setState(() {
      if (q.isEmpty) {
        _filtrados = _todos;
      } else {
        _filtrados = _todos.where((p) {
          final hc = p.numeroHistoriaClinica.toLowerCase();
          final nombre = p.nombre.toLowerCase();
          final apellido = p.apellido.toLowerCase();
          return hc.contains(q) || nombre.contains(q) || apellido.contains(q);
        }).toList();
      }
    });
  }

  Future<void> _refresh() async {
    final list = await PacienteService.getPacientes();
    setState(() {
      _todos = list;
      _aplicarFiltro(_searchController.text);
      _futurePacientes = Future.value(list);
    });
  }

  Future<void> _eliminar(Paciente p) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar paciente'),
        content: Text('¿Seguro que deseas eliminar a ${p.nombre} ${p.apellido}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmado != true) return;

    try {
      await PacienteService.deletePaciente(p.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paciente eliminado')),
      );
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildItem(Paciente p) {
    final antecedentes = (p.antecedentesOculares == null || p.antecedentesOculares!.trim().isEmpty)
        ? 'Sin antecedentes'
        : p.antecedentesOculares!;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          radius: 24,
          child: Text(
            p.nombre.isNotEmpty ? p.nombre[0].toUpperCase() : 'P',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          '${p.nombre} ${p.apellido}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${p.numeroHistoriaClinica}'),
            const SizedBox(height: 2),
            Text('Antecedentes Medico: $antecedentes', maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              tooltip: 'Editar',
              icon: const Icon(Icons.edit),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditarPacienteScreen(paciente: p)),
                );
                _refresh();
              },
            ),
            IconButton(
              tooltip: 'Eliminar',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _eliminar(p),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // AppBar con buscador acoplado
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Pacientes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: _aplicarFiltro,
              decoration: InputDecoration(
                hintText: 'Buscar por HC, nombre o apellido',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Paciente>>(
        future: _futurePacientes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _todos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError && _todos.isEmpty) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (_filtrados.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No hay pacientes que coincidan')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _filtrados.length,
              itemBuilder: (context, index) => _buildItem(_filtrados[index]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CrearPacienteScreen()),
          );
          _refresh();
        },
      ),
    );
  }
}
