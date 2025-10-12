import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/models.dart';
import '../../data/services/MedicoService.dart';
import '../../widgets/cards/medico_card.dart';
import 'crear_medico_screen.dart';
import 'editar_medico_screen.dart';

class GestionarMedicosScreen extends StatefulWidget {
  const GestionarMedicosScreen({super.key});

  @override
  State<GestionarMedicosScreen> createState() => _GestionarMedicosScreenState();
}

class _GestionarMedicosScreenState extends State<GestionarMedicosScreen> {
  final MedicoService _medicoService = MedicoService();
  List<Medico> _medicos = [];
  List<Medico> _medicosFiltrados = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarMedicos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarMedicos() async {
    setState(() => _isLoading = true);
    
    try {
      final medicos = await _medicoService.getAllMedicos();
      setState(() {
        _medicos = medicos;
        _medicosFiltrados = medicos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar médicos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filtrarMedicos(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _medicosFiltrados = _medicos;
      } else {
        _medicosFiltrados = _medicos.where((medico) {
          return medico.nombre.toLowerCase().contains(query.toLowerCase()) ||
                 medico.numeroColegiado.toLowerCase().contains(query.toLowerCase()) ||
                 medico.correo.toLowerCase().contains(query.toLowerCase()) ||
                 medico.especialidadesTexto.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _eliminarMedico(Medico medico) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que deseas eliminar al médico ${medico.nombreCompleto}?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await MedicoService.deleteMedico(medico.id);
        await _cargarMedicos();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Médico ${medico.nombreCompleto} eliminado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar médico: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _irACrearMedico() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CrearMedicoScreen(),
      ),
    );

    if (resultado == true) {
      await _cargarMedicos();
    }
  }

  Future<void> _irAEditarMedico(Medico medico) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarMedicoScreen(medico: medico),
      ),
    );

    if (resultado == true) {
      await _cargarMedicos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Gestión de Médicos',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF17635F),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _cargarMedicos,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filtrarMedicos,
                    decoration: InputDecoration(
                      hintText: 'Buscar médicos...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filtrarMedicos('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contador de resultados
          if (!_isLoading) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_medicosFiltrados.length} médico(s) encontrado(s)',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        _searchController.clear();
                        _filtrarMedicos('');
                      },
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: const Text('Limpiar filtro'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF17635F),
                      ),
                    ),
                ],
              ),
            ),
          ],

          // Lista de médicos
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF17635F),
                    ),
                  )
                : _medicosFiltrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isNotEmpty 
                                  ? Icons.search_off 
                                  : Icons.person_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'No se encontraron médicos con "$_searchQuery"'
                                  : 'No hay médicos registrados',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Intenta con otros términos de búsqueda'
                                  : 'Agrega el primer médico para comenzar',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _cargarMedicos,
                        color: const Color(0xFF17635F),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: _medicosFiltrados.length,
                          itemBuilder: (context, index) {
                            final medico = _medicosFiltrados[index];
                            return MedicoCard(
                              medico: medico,
                              onEdit: () => _irAEditarMedico(medico),
                              onDelete: () => _eliminarMedico(medico),
                              onTap: () => _irAEditarMedico(medico),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _irACrearMedico,
        backgroundColor: const Color(0xFF17635F),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          'Nuevo Médico',
          style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}