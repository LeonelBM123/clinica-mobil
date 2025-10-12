import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/models.dart';

class PatologiaCard extends StatelessWidget {
  final Patologia patologia;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const PatologiaCard({
    super.key,
    required this.patologia,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final gravedadColor = _getGravedadColor(patologia.gravedad);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con título y acciones
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: gravedadColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.medical_services_outlined,
                      color: gravedadColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patologia.nombre,
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        if (patologia.alias.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Alias: ${patologia.alias}',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (showActions) ...[
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Eliminar', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Descripción
              if (patologia.descripcion.isNotEmpty) ...[
                Text(
                  'Descripción:',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  patologia.descripcion,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.grey[800],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Chip de gravedad
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: gravedadColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: gravedadColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getGravedadIcon(patologia.gravedad),
                          size: 14,
                          color: gravedadColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getGravedadText(patologia.gravedad),
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: gravedadColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'ID: ${patologia.id}',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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

  IconData _getGravedadIcon(String gravedad) {
    switch (gravedad.toLowerCase()) {
      case 'leve':
        return Icons.info_outline;
      case 'moderada':
        return Icons.warning_outlined;
      case 'grave':
      case 'severa':
        return Icons.error_outline;
      case 'crítica':
        return Icons.dangerous_outlined;
      default:
        return Icons.help_outline;
    }
  }

  String _getGravedadText(String gravedad) {
    switch (gravedad.toLowerCase()) {
      case 'leve':
        return 'Leve';
      case 'moderada':
        return 'Moderada';
      case 'grave':
        return 'Grave';
      case 'severa':
        return 'Severa';
      case 'crítica':
        return 'Crítica';
      default:
        return gravedad.toUpperCase();
    }
  }
}