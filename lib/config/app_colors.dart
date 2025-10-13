import 'package:flutter/material.dart';

/// Paleta de colores de la Clínica Visionex
class AppColors {
  // Color principal de la marca
  static const Color primary = Color(0xFF17635F);
  static const Color primaryLight = Color(0xFF2A8B87);
  static const Color primaryDark = Color(0xFF0E4A47);

  // Colores de fondo
  static const Color background = Colors.white;
  static final Color backgroundGrey = Colors.grey[50]!;
  static final Color backgroundLight = Colors.grey[100]!;

  // Colores de superficie (cards, containers)
  static const Color surface = Colors.white;
  static final Color surfaceGrey = Colors.grey[50]!;

  // Colores de texto
  static final Color textPrimary = Colors.grey[800]!;
  static final Color textSecondary = Colors.grey[600]!;
  static final Color textLight = Colors.grey[500]!;
  static const Color textOnPrimary = Colors.white;

  // Colores de estado
  static final Color success = Colors.green[600]!;
  static final Color warning = Colors.orange[600]!;
  static final Color error = Colors.red[600]!;
  static final Color info = Colors.blue[600]!;

  // Colores de estado con opacidad
  static final Color successLight = Colors.green[50]!;
  static final Color warningLight = Colors.orange[50]!;
  static final Color errorLight = Colors.red[50]!;
  static final Color infoLight = Colors.blue[50]!;

  // Bordes y divisores
  static final Color border = Colors.grey[200]!;
  static final Color divider = Colors.grey[300]!;

  // Opacidades del color principal
  static Color primaryWithOpacity(double opacity) =>
      primary.withOpacity(opacity);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF5F5F5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
