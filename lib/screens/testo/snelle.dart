import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

enum TestState { initializing, instructions, testingLetter, results }

class SnellenLevel {
  final String name;
  final List<String> letters;
  final double fontSize;

  SnellenLevel({
    required this.name,
    required this.letters,
    required this.fontSize,
  });
}

class SnellenTestScreen extends StatefulWidget {
  const SnellenTestScreen({Key? key}) : super(key: key);

  @override
  _SnellenTestScreenState createState() => _SnellenTestScreenState();
}

class _SnellenTestScreenState extends State<SnellenTestScreen> {
  final SpeechToText _stt = SpeechToText();
  bool _disposed = false;

  // Estados
  TestState _state = TestState.initializing;
  String _currentEye = 'derecho';

  // Niveles
  final List<SnellenLevel> _levels = [
    SnellenLevel(name: "20/200", letters: ["E"], fontSize: 120.0),
    SnellenLevel(name: "20/100", letters: ["F", "P"], fontSize: 90.0),
    SnellenLevel(name: "20/70", letters: ["T", "O", "Z"], fontSize: 70.0),
    SnellenLevel(name: "20/50", letters: ["L", "P", "E", "D"], fontSize: 50.0),
    SnellenLevel(
      name: "20/40",
      letters: ["F", "C", "Z", "B", "D"],
      fontSize: 40.0,
    ),
    SnellenLevel(
      name: "20/30",
      letters: ["F", "L", "T", "H", "K", "C"],
      fontSize: 30.0,
    ),
    SnellenLevel(
      name: "20/25",
      letters: ["D", "F", "N", "P", "O", "T", "E"],
      fontSize: 25.0,
    ),
    SnellenLevel(
      name: "20/20",
      letters: ["F", "E", "L", "O", "P", "Z", "D", "T"],
      fontSize: 20.0,
    ),
  ];

  // Progreso
  int _levelIndex = 0;
  int _letterIndex = 0;
  int _correct = 0;
  int _attempts = 0;

  // Config
  static const double passThreshold = 0.6;
  static const int maxRetriesPerLetter = 3;
  String _currentLetter = '';
  String _lastHeardRaw = '';
  String? _localeId;

  // Voz
  bool _isListening = false;
  bool _capturedThisLetter = false;
  int _voiceRetries = 0;
  Timer? _shotTimer;

  // Resultados
  final List<String> _testResults = [];

  // Letras válidas del test de Snellen
  final Set<String> _snellenSet = const {
    'C',
    'D',
    'E',
    'F',
    'L',
    'N',
    'O',
    'P',
    'T',
    'Z',
    'B',
    'H',
    'K',
  };

  // Mapeo de nombres de letras a su representación
  final Map<String, String> _aliasToLetter = const {
    // Español
    'ELE': 'L', 'TE': 'T', 'DE': 'D', 'CE': 'C', 'PE': 'P', 'ENE': 'N',
    'ZETA': 'Z', 'BE': 'B', 'ACHE': 'H', 'KA': 'K', 'OH': 'O', 'EFE': 'F',
    // Inglés
    'SEE': 'C', 'DEE': 'D', 'EEE': 'E', 'EFF': 'F', 'ELL': 'L',
    'TEE': 'T', 'PEE': 'P', 'ZEE': 'Z',
  };

  @override
  void initState() {
    super.initState();
    _initSTT();
  }

  Future<void> _initSTT() async {
    setState(() => _state = TestState.initializing);

    try {
      if (!kIsWeb) {
        final status = await Permission.microphone.request();
        if (!status.isGranted) {
          _showError('Permiso de micrófono requerido.');
          setState(() => _state = TestState.instructions);
          return;
        }
      }

      final available = await _stt.initialize(
        onError: (err) {
          debugPrint('STT Error: ${err.errorMsg}');
          if (mounted) setState(() => _isListening = false);
        },
        onStatus: (status) {
          debugPrint('STT Status: $status');
          if (!mounted) return;

          final wasListening = _isListening;
          _isListening = (status == 'listening');

          if (wasListening &&
              !_isListening &&
              _state == TestState.testingLetter) {
            _shotTimer?.cancel();
            if (!_capturedThisLetter) {
              _voiceRetries++;
              if (_voiceRetries <= maxRetriesPerLetter) {
                Future.delayed(const Duration(milliseconds: 250), () {
                  if (!_disposed && _state == TestState.testingLetter) {
                    _startShot();
                  }
                });
              } else {
                _handleRecognized(null);
              }
            }
          }

          if (mounted) setState(() {});
        },
      );

      if (!available) {
        _showError('Reconocimiento de voz no disponible.');
      }

      final sysLocale = await _stt.systemLocale();
      _localeId = sysLocale?.localeId ?? 'es_ES';

      setState(() => _state = TestState.instructions);
    } catch (e) {
      debugPrint('Init error: $e');
      _showError('Error inicializando reconocimiento.');
      setState(() => _state = TestState.instructions);
    }
  }

  void _startTest() {
    _levelIndex = 0;
    _resetLevel();
    _state = TestState.testingLetter;
    setState(() {});
    _beginLetter();
  }

  void _resetLevel() {
    _letterIndex = 0;
    _correct = 0;
    _attempts = 0;
    _currentLetter = _levels[_levelIndex].letters[_letterIndex];
    _lastHeardRaw = '';
  }

  void _beginLetter() {
    _capturedThisLetter = false;
    _voiceRetries = 0;
    _lastHeardRaw = '';
    _startShot();
  }

  Future<void> _startShot() async {
    if (_disposed || _isListening || _state != TestState.testingLetter) return;

    if (!kIsWeb) {
      final status = await Permission.microphone.status;
      if (!status.isGranted) {
        _showError('Activa el micrófono en Ajustes.');
        await openAppSettings();
        return;
      }
    }

    try {
      _capturedThisLetter = false;
      setState(() => _isListening = true);

      await _stt.listen(
        localeId: _localeId ?? 'es_ES',
        listenMode: ListenMode.confirmation,
        partialResults: true,
        listenFor: const Duration(seconds: 4),
        pauseFor: const Duration(milliseconds: 900),
        onResult: (result) async {
          if (_disposed || _capturedThisLetter) return;

          _lastHeardRaw = result.recognizedWords;
          if (mounted) setState(() {});

          final candidate = _mapToSnellenLetter(_lastHeardRaw);
          if (candidate != null && !_capturedThisLetter) {
            _capturedThisLetter = true;
            _shotTimer?.cancel();

            try {
              await _stt.stop();
            } catch (_) {}

            Future.delayed(const Duration(milliseconds: 120), () {
              if (!_disposed) _handleRecognized(candidate);
            });
          }
        },
        cancelOnError: true,
      );

      _shotTimer?.cancel();
      _shotTimer = Timer(const Duration(seconds: 5), () async {
        if (_isListening && !_capturedThisLetter) {
          try {
            await _stt.stop();
          } catch (_) {}
        }
      });
    } catch (e) {
      debugPrint('startShot error: $e');
      setState(() => _isListening = false);

      Future.delayed(const Duration(milliseconds: 500), () {
        if (!_disposed &&
            _state == TestState.testingLetter &&
            !_capturedThisLetter) {
          _voiceRetries++;
          if (_voiceRetries <= maxRetriesPerLetter) {
            _startShot();
          } else {
            _handleRecognized(null);
          }
        }
      });
    }
  }

  void _handleRecognized(String? mappedLetter) {
    _shotTimer?.cancel();
    _isListening = false;

    final isCorrect =
        (mappedLetter != null) &&
        (mappedLetter == _currentLetter.toUpperCase());

    if (isCorrect) _correct++;
    _nextLetterOrEvaluate();
  }

  void _nextLetterOrEvaluate() {
    _attempts++;

    if (_letterIndex < _levels[_levelIndex].letters.length - 1) {
      _letterIndex++;
      _currentLetter = _levels[_levelIndex].letters[_letterIndex];
      _beginLetter();
      setState(() {});
    } else {
      _evaluateLevel();
    }
  }

  void _evaluateLevel() {
    final accuracy =
        _levels[_levelIndex].letters.isEmpty
            ? 0.0
            : _correct / _levels[_levelIndex].letters.length;

    if (accuracy >= passThreshold) {
      _testResults.add('${_levels[_levelIndex].name}: APROBADO');

      if (_levelIndex < _levels.length - 1) {
        _levelIndex++;
        _resetLevel();
        setState(() {});
        _beginLetter();
      } else {
        _finishEye();
      }
    } else {
      _finishEye();
    }
  }

  void _finishEye() {
    final lastLevel =
        _testResults.isNotEmpty
            ? _testResults.last.split(':').first
            : 'Ninguno';
    _testResults.add('Ojo $_currentEye: $lastLevel');

    if (_currentEye == 'derecho') {
      _currentEye = 'izquierdo';
      _levelIndex = 0;
      _resetLevel();
      _state = TestState.instructions;
    } else {
      _state = TestState.results;
    }
    setState(() {});
  }

  String? _mapToSnellenLetter(String raw) {
    if (raw.trim().isEmpty) return null;

    final text = raw.toUpperCase().replaceAll(RegExp(r'[^A-Z\s]'), '').trim();
    if (text.isEmpty) return null;

    // 1) Búsqueda por letra directa
    if (text.length == 1 && _snellenSet.contains(text)) {
      return text;
    }

    // 2) Búsqueda por nombre de letra
    for (final token in text.split(RegExp(r'\s+'))) {
      final t = token.trim();
      if (t.isEmpty) continue;

      // Letra directa en el token
      if (t.length == 1 && _snellenSet.contains(t)) {
        return t;
      }

      // Alias exacto
      if (_aliasToLetter.containsKey(t)) {
        final letter = _aliasToLetter[t]!;
        if (_snellenSet.contains(letter)) return letter;
      }
    }

    // 3) Búsqueda por inclusión de alias
    for (final entry in _aliasToLetter.entries) {
      if (text.contains(entry.key)) {
        final letter = entry.value;
        if (_snellenSet.contains(letter)) return letter;
      }
    }

    // 4) Búsqueda fuzzy con Levenshtein
    final candidates =
        <String>[]
          ..addAll(_aliasToLetter.keys)
          ..addAll(_snellenSet);

    String? bestMatch;
    int bestDist = 999;

    for (final candidate in candidates) {
      final distance = _levenshtein(text, candidate);
      if (distance < bestDist) {
        bestDist = distance;
        bestMatch = candidate;
      }
    }

    if (bestMatch != null && bestDist <= 2) {
      final mapped = _aliasToLetter[bestMatch] ?? bestMatch;
      if (_snellenSet.contains(mapped)) {
        return mapped;
      }
    }

    return null;
  }

  int _levenshtein(String a, String b) {
    final m = a.length;
    final n = b.length;

    if (m == 0) return n;
    if (n == 0) return m;

    final dp = List.generate(m + 1, (_) => List<int>.filled(n + 1, 0));

    for (int i = 0; i <= m; i++) {
      dp[i][0] = i;
    }
    for (int j = 0; j <= n; j++) {
      dp[0][j] = j;
    }

    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        dp[i][j] = min(
          dp[i - 1][j] + 1,
          min(dp[i][j - 1] + 1, dp[i - 1][j - 1] + cost),
        );
      }
    }

    return dp[m][n];
  }

  String _generateReport() {
    final results = <String, String>{};

    for (final result in _testResults) {
      if (result.contains('Ojo derecho:')) {
        results['derecho'] = result.split(': ')[1];
      } else if (result.contains('Ojo izquierdo:')) {
        results['izquierdo'] = result.split(': ')[1];
      }
    }

    final buffer = StringBuffer();
    buffer.writeln('REPORTE DE AGUDEZA VISUAL\n');
    buffer.writeln('Ojo Derecho: ${results['derecho'] ?? 'No evaluado'}');
    buffer.writeln('Ojo Izquierdo: ${results['izquierdo'] ?? 'No evaluado'}\n');

    final hasGood = results.values.any(
      (r) => r.contains('20/20') || r.contains('20/25'),
    );
    final hasModerate = results.values.any(
      (r) => r.contains('20/30') || r.contains('20/40'),
    );

    if (hasGood) {
      buffer.writeln('EVALUACIÓN: Agudeza visual normal a buena');
    } else if (hasModerate) {
      buffer.writeln(
        'EVALUACIÓN: Agudeza visual moderada - Revisión recomendada',
      );
    } else {
      buffer.writeln(
        'EVALUACIÓN: Deficiencia visual detectada - Consulta oftalmológica necesaria',
      );
    }

    buffer.writeln(
      '\nEste es un tamizaje preliminar. Consulte a un especialista.',
    );

    return buffer.toString();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _shotTimer?.cancel();
    try {
      _stt.stop();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Test de Snellen - Ojo $_currentEye',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF17635F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            try {
              _stt.stop();
            } catch (_) {}
            Navigator.pop(context);
          },
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case TestState.initializing:
        return _buildInitializing();
      case TestState.instructions:
        return _buildInstructions();
      case TestState.testingLetter:
        return _buildTesting();
      case TestState.results:
        return _buildResults();
    }
  }

  Widget _buildInitializing() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 16),
          Text(
            'Inicializando...',
            style: GoogleFonts.roboto(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.visibility, size: 80, color: Colors.white),
            const SizedBox(height: 24),
            Text(
              'Test de Agudeza Visual',
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Instrucciones:\n'
                '• Cúbrase el ojo ${_currentEye == 'derecho' ? 'izquierdo' : 'derecho'}\n'
                '• Mantenga el teléfono a ~60 cm\n'
                '• Diga en voz alta la letra que ve en pantalla\n'
                '• Avanzará automáticamente al reconocer su voz',
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 26),
            ElevatedButton(
              onPressed: _startTest,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF17635F),
                padding: const EdgeInsets.symmetric(
                  horizontal: 44,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: Text(
                'COMENZAR',
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTesting() {
    final level = _levels[_levelIndex];

    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Nivel ${_levelIndex + 1} - ${level.name}',
                  style: GoogleFonts.roboto(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _currentLetter,
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: level.fontSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Intentos: ${min(_attempts, level.letters.length)}/${level.letters.length}  •  Aciertos: $_correct',
                  style: GoogleFonts.roboto(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  size: 52,
                  color: _isListening ? Colors.redAccent : Colors.grey,
                ),
                const SizedBox(height: 8),
                Text(
                  _isListening
                      ? 'Di la letra ahora...'
                      : 'Reintentando reconocimiento...',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                if (_voiceRetries > 0)
                  Text(
                    'Reintento ${min(_voiceRetries, maxRetriesPerLetter)}/$maxRetriesPerLetter',
                    style: GoogleFonts.roboto(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                const SizedBox(height: 10),
                if (_lastHeardRaw.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Escuché: "$_lastHeardRaw"',
                      style: GoogleFonts.roboto(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Icon(Icons.assessment, size: 80, color: Colors.green),
          const SizedBox(height: 12),
          Text(
            'REPORTE DE RESULTADOS',
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _generateReport(),
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _currentEye = 'derecho';
                    _testResults.clear();
                    _levelIndex = 0;
                    _resetLevel();
                    _state = TestState.instructions;
                    setState(() {});
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('REPETIR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
                    backgroundColor: const Color(0xFF17635F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
