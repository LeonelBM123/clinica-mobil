import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'snelle.dart';
import 'ishihara.dart'; // <-- Importa el test de Ishihara

class TestScreen extends StatelessWidget {
  final String grupoNombre;

  const TestScreen({super.key, required this.grupoNombre});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Test Oftalmológicos',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF17635F),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Volver al Dashboard',
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[100]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header de bienvenida
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(Icons.visibility, size: 48, color: Color(0xFF17635F)),
                    SizedBox(height: 12),
                    Text(
                      'Test Oftalmológicos',
                      style: GoogleFonts.roboto(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF17635F),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Evalúa tu salud visual con nuestros test especializados',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Sección de test disponibles
              Text(
                'Test Disponibles',
                style: GoogleFonts.roboto(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF17635F),
                ),
              ),
              SizedBox(height: 16),

              // Test Snellen
              _buildTestCard(
                context,
                'Test de Snellen',
                'Evaluación de Agudeza Visual',
                'Este test evalúa la capacidad de ver objetos nítidamente a diferentes distancias. Ayuda a detectar problemas de refracción como miopía (dificultad para ver de lejos) e hipermetropía (dificultad para ver de cerca).',
                'Diagnostica: Miopía, Hipermetropía, Astigmatismo',
                Icons.remove_red_eye,
                Color(0xFF2196F3),
                () => _iniciarSnellen(context),
              ),

              SizedBox(height: 16),

              // Test Ishihara
              _buildTestCard(
                context,
                'Test de Ishihara',
                'Evaluación de Percepción del Color',
                'Este test detecta deficiencias en la visión del color, comúnmente conocido como daltonismo. Utiliza láminas con números o figuras formadas por puntos de colores para evaluar la capacidad de distinguir colores.',
                'Diagnostica: Daltonismo (Protanopia, Deuteranopia, Tritanopia)',
                Icons.palette,
                Color(0xFF4CAF50),
                () => _iniciarIshihara(context),
              ),

              SizedBox(height: 16),

              // Test Rejilla de Amsler
              _buildTestCard(
                context,
                'Rejilla de Amsler',
                'Evaluación de Visión Central',
                'Esta prueba evalúa la función de la mácula, la parte central de la retina responsable de la visión detallada. Es fundamental para detectar problemas en la visión central como degeneración macular.',
                'Diagnostica: Degeneración Macular, Metamorfopsia, Escotomas Centrales',
                Icons.grid_on,
                Color(0xFF9C27B0),
                () => _iniciarTest(context, 'Amsler'),
              ),

              SizedBox(height: 24),

              // Nota informativa
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber[200]!, width: 1),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 32,
                      color: Colors.amber[800],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Información Importante',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Estos test son herramientas de evaluación preliminar y no reemplazan un examen oftalmológico profesional. Para un diagnóstico definitivo, consulte con un especialista.',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.amber[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestCard(
    BuildContext context,
    String title,
    String subtitle,
    String description,
    String diagnostics,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del test
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Descripción
            Text(
              description,
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),

            SizedBox(height: 12),

            // Diagnósticos
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.medical_services, size: 16, color: color),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      diagnostics,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Botón de iniciar test
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Iniciar Test',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _iniciarSnellen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SnellenTestScreen()),
    );
  }

  void _iniciarIshihara(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => IshiharaTestScreen()),
    );
  }

  void _iniciarTest(BuildContext context, String testType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Test $testType'),
        content: Text(
          'Esta funcionalidad estará disponible próximamente. Se redirigirá al test de $testType.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
