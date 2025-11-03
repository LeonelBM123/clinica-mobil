import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum IshiharaTestState { initializing, instructions, testing, results }

class IshiharaPlate {
  final String imagePath; // <-- Ruta real de la imagen
  final String correctAnswer;
  final String description;
  final String deficiencyType;
  final List<String> answerOptions; // Opciones para los botones

  IshiharaPlate({
    required this.imagePath,
    required this.correctAnswer,
    required this.description,
    required this.deficiencyType,
    required this.answerOptions,
  });
}

class IshiharaTestScreen extends StatefulWidget {
  @override
  _IshiharaTestScreenState createState() => _IshiharaTestScreenState();
}

class _IshiharaTestScreenState extends State<IshiharaTestScreen> {
  IshiharaTestState _state = IshiharaTestState.initializing;
  int _currentPlateIndex = 0;
  final List<String> _userAnswers = [];
  final List<bool> _results = [];
  Timer? _initTimer;

  // --- LISTA DE 5 LÁMINAS CLAVE ---
  final List<IshiharaPlate> _plates = [
    IshiharaPlate(
      imagePath: 'assets/imagenes/ishihara/plate_1.png',
      correctAnswer: '12',
      description: 'Lámina de control — Plate 1',
      deficiencyType: 'Control',
      answerOptions: ['12', '1', '2', '8'],
    ),
    IshiharaPlate(
      imagePath: 'assets/imagenes/ishihara/Ishihara_9.png',
      correctAnswer: '74',
      description: 'Plate 9',
      deficiencyType: 'Rojo-Verde',
      answerOptions: ['74', '21', '7', '4'],
    ),
    IshiharaPlate(
      imagePath: 'assets/imagenes/ishihara/Ishihara_11.png',
      correctAnswer: '6',
      description: 'Plate 11',
      deficiencyType: 'Rojo-Verde',
      answerOptions: ['6', '5', '8', '9'],
    ),
    IshiharaPlate(
      imagePath: 'assets/imagenes/ishihara/Ishihara_19.png',
      correctAnswer: 'NO VEO',
      description: 'Plate 19',
      deficiencyType: 'Rojo-Verde',
      answerOptions: ['2', '5', '7'],
    ),
    IshiharaPlate(
      imagePath: 'assets/imagenes/ishihara/Ishihara_23.png',
      correctAnswer: '42',
      description: 'Plate 23',
      deficiencyType: 'Rojo-Verde',
      answerOptions: ['42', '45', '12'],
    ),
  ];

  // --- FIN DE LA LISTA ---

  @override
  void initState() {
    super.initState();
    _initTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _state = IshiharaTestState.instructions);
      }
    });
  }

  @override
  void dispose() {
    _initTimer?.cancel();
    super.dispose();
  }

  void _startTest() {
    setState(() {
      _state = IshiharaTestState.testing;
      _currentPlateIndex = 0;
      _userAnswers.clear();
      _results.clear();
    });
  }

  void _submitAnswer(String answer) {
    final plate = _plates[_currentPlateIndex];
    final isCorrect =
        answer.trim().toUpperCase() == plate.correctAnswer.toUpperCase();

    _userAnswers.add(answer);
    _results.add(isCorrect);

    if (_currentPlateIndex < _plates.length - 1) {
      setState(() => _currentPlateIndex++);
    } else {
      setState(() => _state = IshiharaTestState.results);
    }
  }

  // --- REPORTE CORREGIDO (Para 5 Láminas) ---
  String _generateReport() {
    int correctAnswers = _results.where((r) => r).length;
    int totalPlates = _plates.length;
    int errors = totalPlates - correctAnswers;

    String report = 'REPORTE DE PERCEPCIÓN DEL COLOR\n';
    report += '═' * 40 + '\n\n';
    report += 'RESULTADOS GENERALES\n';
    report += '─' * 40 + '\n';
    report += 'Láminas totales: $totalPlates\n';
    report += 'Respuestas correctas: $correctAnswers\n';
    report += 'Errores: $errors\n\n';

    report += 'EVALUACIÓN FINAL\n';
    report += '─' * 40 + '\n';

    // --- NUEVA LÓGICA DE REPORTE (5 PLACAS) ---
    bool controlFailed = !_results[0]; // Chequea la lámina "12"
    int keyErrors = 0;
    for (int i = 1; i < _plates.length; i++) {
      // Chequea de la 2 a la 5
      if (!_results[i]) {
        keyErrors++;
      }
    }

    if (controlFailed) {
      report += '⚠ TEST INVÁLIDO\n\n';
      report += 'No se detectó una respuesta correcta en la\n';
      report += 'lámina de control (12). Asegúrese de tener\n';
      report += 'buena iluminación y repita el test.\n';
    } else if (keyErrors == 0) {
      report += '✓ VISIÓN DE COLOR NORMAL\n\n';
      report += 'Sus respuestas son consistentes con una\n';
      report += 'visión de color normal.\n';
    } else {
      report += '⚠ POSIBLE DEFICIENCIA DE COLOR\n\n';
      report += 'Se detectaron $keyErrors errores en las láminas de prueba.\n';
      report += 'Esto sugiere una posible deficiencia en la\n';
      report += 'percepción del color (Rojo-Verde).\n';
    }

    report += '\n' + '═' * 40 + '\n';
    report += 'NOTA IMPORTANTE\n';
    report += '─' * 40 + '\n';
    report += 'Este es un test de tamizaje preliminar.\n';
    report += 'Para un diagnóstico definitivo, consulte con un\n';
    report += 'oftalmólogo u optometrista certificado.\n';

    return report;
  }

  List<Map<String, dynamic>> _generateResultsList() {
    List<Map<String, dynamic>> resultsList = [];
    for (int i = 0; i < _plates.length; i++) {
      resultsList.add({
        'plateNumber': i + 1,
        'imagePath': _plates[i].imagePath,
        'correctAnswer': _plates[i].correctAnswer,
        'userAnswer': _userAnswers[i],
        'isCorrect': _results[i],
        'deficiencyType': _plates[i].deficiencyType,
        'description': _plates[i].description,
      });
    }
    return resultsList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Test de Ishihara (5 Láminas)', // Título actualizado
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case IshiharaTestState.initializing:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF4CAF50)),
              const SizedBox(height: 16),
              Text(
                'Preparando test...',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        );

      case IshiharaTestState.instructions:
        return _buildInstructions();

      case IshiharaTestState.testing:
        return _buildTestingView();

      case IshiharaTestState.results:
        return _buildResults();
    }
  }

  Widget _buildInstructions() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.palette,
                size: 80,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Test de Ishihara',
              style: GoogleFonts.roboto(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Evaluación Rápida de Percepción del Color', // Subtítulo actualizado
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF4CAF50),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Instrucciones',
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInstructionItem(
                    '1',
                    'Ajusta el brillo de tu pantalla al máximo',
                  ),
                  _buildInstructionItem(
                    '2',
                    'Mantén el dispositivo a una distancia cómoda',
                  ),
                  _buildInstructionItem(
                    '3',
                    'Selecciona el número que ves en la lámina',
                  ),
                  _buildInstructionItem(
                    '4',
                    'Si no ves ningún número, presiona "No veo nada"',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber[200]!, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.amber[800],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No uses filtros de luz azul (modo noche)',
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              color: Colors.amber[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'COMENZAR TEST (${_plates.length} LÁMINAS)',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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

  Widget _buildInstructionItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.roboto(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestingView() {
    final plate = _plates[_currentPlateIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Indicador de Progreso
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lámina ${_currentPlateIndex + 1} de ${_plates.length}',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${(((_currentPlateIndex + 1) / _plates.length) * 100).toInt()}%',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (_currentPlateIndex + 1) / _plates.length,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF4CAF50),
                  ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Imagen de la Lámina
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  plate.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Error: No se encontró la imagen.\nAsegúrate de que "${plate.imagePath}" esté en tu pubspec.yaml',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(color: Colors.red),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Botones de Opciones
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Qué número ves?',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    ...plate.answerOptions.map((answer) {
                      return ElevatedButton(
                        onPressed: () => _submitAnswer(answer),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4CAF50).withOpacity(0.1),
                          foregroundColor: Color(0xFF4CAF50),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          answer,
                          style: GoogleFonts.roboto(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                    // Botón "No veo nada"
                    ElevatedButton(
                      onPressed: () => _submitAnswer('NO VEO'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.grey[700],
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'No veo nada',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final report = _generateReport();
    final resultsList = _generateResultsList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Encabezado
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.assessment,
                    size: 60,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Test Completado',
                  style: GoogleFonts.roboto(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Reporte Resumido (Seguro)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.description,
                      color: Color(0xFF4CAF50),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Reporte Preliminar',
                      style: GoogleFonts.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SelectableText(
                    report, // <-- Usando el reporte seguro
                    style: GoogleFonts.robotoMono(
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _state = IshiharaTestState.instructions;
                      _currentPlateIndex = 0;
                      _userAnswers.clear();
                      _results.clear();
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('REPETIR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check),
                  label: const Text('FINALIZAR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
