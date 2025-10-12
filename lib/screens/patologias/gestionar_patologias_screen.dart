import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/models.dart';
import '../../data/services/PatologiaService.dart';
import '../../widgets/cards/patologia_card.dart';
import 'crear_patologia_screen.dart';
import 'editar_patologia_screen.dart';

class GestionarPatologiasScreen extends StatefulWidget {
  const GestionarPatologiasScreen({super.key});

  @override
  State<GestionarPatologiasScreen> createState() => _GestionarPatologiasScreenState();
}

class _GestionarPatologiasScreenState extends State<GestionarPatologiasScreen> {
  final PatologiaService _patologiaService = PatologiaService();
  List<Patologia> _patologias = [];
  List<Patologia> _patologiasFiltradas = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filtroGravedad = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarPatologias();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarPatologias() async {
    setState(() => _isLoading = true);
    
    try {
      final patologias = await _patologiaService.getAllPatologias();
      setState(() {
        _patologias = patologias;
        _patologiasFiltradas = patologias;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar patologías: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filtrarPatologias() {
    setState(() {
      _patologiasFiltradas = _patologias.where((patologia) {
        bool coincideBusqueda = _searchQuery.isEmpty ||
            patologia.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            patologia.alias.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            patologia.descripcion.toLowerCase().contains(_searchQuery.toLowerCase());

        bool coincideGravedad = _filtroGravedad.isEmpty ||
            patologia.gravedad.toLowerCase() == _filtroGravedad.toLowerCase();

        return coincideBusqueda && coincideGravedad;
      }).toList();
    });
  }

  void _buscarPatologias(String query) {
    _searchQuery = query;
    _filtrarPatologias();
  }

  void _filtrarPorGravedad(String gravedad) {
    setState(() {
      _filtroGravedad = gravedad;
    });
    _filtrarPatologias();
  }

  Future<void> _eliminarPatologia(Patologia patologia) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que deseas eliminar la patología "${patologia.nombre}"?\n\n'
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
        await PatologiaService.deletePatologia(patologia.id);
        await _cargarPatologias();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Patología "${patologia.nombre}" eliminada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar patología: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _irACrearPatologia() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CrearPatologiaScreen(),
      ),
    );

    if (resultado == true) {
      await _cargarPatologias();
    }
  }

  Future<void> _irAEditarPatologia(Patologia patologia) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarPatologiaScreen(patologia: patologia),
      ),
    );

    if (resultado == true) {
      await _cargarPatologias();
    }
  }

  Widget _construirFiltrosGravedad() {
    final gravedades = ['Leve', 'Moderada', 'Grave', 'Severa', 'Crítica'];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          FilterChip(
            label: Text('Todas'),
            selected: _filtroGravedad.isEmpty,
            onSelected: (_) => _filtrarPorGravedad(''),
            backgroundColor: Colors.grey[200],
            selectedColor: const Color(0xFF17635F).withOpacity(0.2),
            checkmarkColor: const Color(0xFF17635F),
          ),
          const SizedBox(width: 8),
          ...gravedades.map((gravedad) {
            final isSelected = _filtroGravedad.toLowerCase() == gravedad.toLowerCase();
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(gravedad),
                selected: isSelected,
                onSelected: (_) => _filtrarPorGravedad(isSelected ? '' : gravedad),
                backgroundColor: Colors.grey[200],
                selectedColor: _getGravedadColor(gravedad).withOpacity(0.2),
                checkmarkColor: _getGravedadColor(gravedad),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Color _getGravedadColor(String gravedad) {
    switch (gravedad.toLowerCase()) {
      case 'leve':
        return Colors.green;
      case 'moderada':
        return Colors.orange;
      case 'grave':
      case 'severa':
        return Colors.red;
      case 'crítica':
        return Colors.red[900]!;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Gestión de Patologías',
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
            onPressed: _cargarPatologias,
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
            child: TextField(
              controller: _searchController,
              onChanged: _buscarPatologias,
              decoration: InputDecoration(
                hintText: 'Buscar patologías...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _buscarPatologias('');
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

          // Filtros de gravedad
          const SizedBox(height: 16),
          _construirFiltrosGravedad(),

          // Contador de resultados
          if (!_isLoading) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_patologiasFiltradas.length} patología(s) encontrada(s)',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (_searchQuery.isNotEmpty || _filtroGravedad.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _filtroGravedad = '';
                        });
                        _filtrarPatologias();
                      },
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: const Text('Limpiar filtros'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF17635F),
                      ),
                    ),
                ],
              ),
            ),
          ],

          // Lista de patologías
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF17635F),
                    ),
                  )
                : _patologiasFiltradas.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isNotEmpty || _filtroGravedad.isNotEmpty
                                  ? Icons.search_off 
                                  : Icons.medical_services_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty || _filtroGravedad.isNotEmpty
                                  ? 'No se encontraron patologías con los filtros aplicados'
                                  : 'No hay patologías registradas',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isNotEmpty || _filtroGravedad.isNotEmpty
                                  ? 'Intenta con otros términos o limpia los filtros'
                                  : 'Agrega la primera patología para comenzar',
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
                        onRefresh: _cargarPatologias,
                        color: const Color(0xFF17635F),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: _patologiasFiltradas.length,
                          itemBuilder: (context, index) {
                            final patologia = _patologiasFiltradas[index];
                            return PatologiaCard(
                              patologia: patologia,
                              onEdit: () => _irAEditarPatologia(patologia),
                              onDelete: () => _eliminarPatologia(patologia),
                              onTap: () => _irAEditarPatologia(patologia),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _irACrearPatologia,
        backgroundColor: const Color(0xFF17635F),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          'Nueva Patología',
          style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}