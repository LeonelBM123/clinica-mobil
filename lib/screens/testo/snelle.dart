import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

enum TestState {
  initializing,
  instructions,
  showingLetters,
  evaluating,
  results,
}

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
  @override
  _SnellenTestScreenState createState() => _SnellenTestScreenState();
}

class _SnellenTestScreenState extends State<SnellenTestScreen> {
  final SpeechToText _speechToText = SpeechToText();

  TestState _currentState = TestState.initializing;
  int _currentLevel = 0;
  String _currentEye = 'derecho';
  List<String> _currentLetters = [];
  List<String> _recognizedWords = [];
  bool _isListening = false;
  bool _isProcessingResponse = false;
  int _consecutiveErrors = 0;

  // Control robusto de escucha
  bool _disposed = false;
  bool _wantMic = false; // Deseo de mantener mic encendido
  bool _restartLock = false; // Evita reinicios en ráfaga
  DateTime _lastListenStarted = DateTime.fromMillisecondsSinceEpoch(0);
  Timer? _watchdog; // Vigila y relanza si se apaga
  Timer? _restartDebounce; // Debounce de reinicio
  double _inputLevel = 0; // nivel de sonido para UI
  String _currentRecognizedText = '';
  String? _localeId;

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

  final Map<String, String> _letterMapping = const {
    'A': 'A',
    'AH': 'A',
    'AA': 'A',
    'B': 'B',
    'BE': 'B',
    'BEE': 'B',
    'C': 'C',
    'CE': 'C',
    'SEE': 'C',
    'SI': 'C',
    'D': 'D',
    'DE': 'D',
    'DEE': 'D',
    'E': 'E',
    'EH': 'E',
    'EEE': 'E',
    'F': 'F',
    'EFE': 'F',
    'EFF': 'F',
    'G': 'G',
    'GE': 'G',
    'GEE': 'G',
    'H': 'H',
    'ACHE': 'H',
    'HACHE': 'H',
    'I': 'I',
    'II': 'I',
    'J': 'J',
    'JOTA': 'J',
    'K': 'K',
    'KA': 'K',
    'CAY': 'K',
    'L': 'L',
    'ELE': 'L',
    'ELL': 'L',
    'M': 'M',
    'EME': 'M',
    'EM': 'M',
    'N': 'N',
    'ENE': 'N',
    'EN': 'N',
    'O': 'O',
    'OH': 'O',
    'OO': 'O',
    'P': 'P',
    'PE': 'P',
    'PEE': 'P',
    'Q': 'Q',
    'CU': 'Q',
    'QUE': 'Q',
    'R': 'R',
    'ERE': 'R',
    'ARE': 'R',
    'ERRE': 'R',
    'S': 'S',
    'ESE': 'S',
    'ES': 'S',
    'T': 'T',
    'TE': 'T',
    'TEE': 'T',
    'U': 'U',
    'UU': 'U',
    'V': 'V',
    'VE': 'V',
    'UVE': 'V',
    'W': 'W',
    'UVE DOBLE': 'W',
    'DOBLE VE': 'W',
    'X': 'X',
    'EQUIS': 'X',
    'Y': 'Y',
    'YE': 'Y',
    'I GRIEGA': 'Y',
    'Z': 'Z',
    'ZETA': 'Z',
    'ZEDA': 'Z',
    'CETA': 'Z',
  };

  final List<String> _testResults = [];

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    if (_disposed) return;
    setState(() => _currentState = TestState.initializing);

    try {
      if (!kIsWeb) {
        final status = await Permission.microphone.request();
        if (!status.isGranted) {
          _showError('Permiso de micrófono requerido.');
          return;
        }
      }

      final available = await _speechToText.initialize(
        onError: (error) {
          print('STT Error: $error');
          if (_disposed) return;

          final msg = (error.errorMsg ?? '').toLowerCase();

          // Manejo específico de errores comunes
          if (msg.contains('busy')) {
            _showError('Micrófono ocupado. Espera un momento.');
            _scheduleRestart(const Duration(milliseconds: 1200));
            return;
          }
          if (msg.contains('timeout') || msg.contains('no_match')) {
            // No se detectó voz o no coincidió: reintentar suave
            _scheduleRestart(const Duration(milliseconds: 800));
            return;
          }
          // Otros errores: intenta reinicio suave
          _scheduleRestart(const Duration(milliseconds: 1000));
        },
        onStatus: (status) {
          print('STT Status: $status');
          if (_disposed) return;

          if (mounted) {
            setState(() => _isListening = (status == 'listening'));
          }

          // Si se apagó y queremos mic encendido, relanzar con debounce
          if (status == 'notListening' && _wantMic && !_isProcessingResponse) {
            _scheduleRestart(const Duration(milliseconds: 600));
          }
        },
      );

      if (!available) {
        _showError('Reconocimiento de voz no disponible.');
        return;
      }

      // Idioma por defecto del sistema
      final sysLocale = await _speechToText.systemLocale();
      _localeId = sysLocale?.localeId ?? 'es_ES';

      // Watchdog que mantiene vivo el micrófono
      _watchdog = Timer.periodic(const Duration(seconds: 2), (_) {
        if (_disposed) return;
        if (_wantMic && !_isProcessingResponse && !_speechToText.isListening) {
          _scheduleRestart(const Duration(milliseconds: 500));
        }
      });

      if (!_disposed) {
        setState(() => _currentState = TestState.instructions);
      }
    } catch (e) {
      print('Error inicializando: $e');
      _showError('Error al inicializar reconocimiento de voz.');
    }
  }

  Future<void> _checkMicrophonePermission() async {
    if (!kIsWeb) {
      final status = await Permission.microphone.status;
      if (!status.isGranted) {
        _showError('Permiso de micrófono denegado. Actívalo en Ajustes.');
        await openAppSettings();
      }
    }
  }

  void _startTest() {
    if (_disposed) return;
    _startLevel();
  }

  void _startLevel() {
    if (_disposed || _currentLevel >= _levels.length) {
      _completeEye();
      return;
    }

    setState(() {
      _currentState = TestState.showingLetters;
      _currentLetters = _levels[_currentLevel].letters;
      _recognizedWords.clear();
      _currentRecognizedText = '';
      _isProcessingResponse = false;
    });

    // Arrancar escucha persistente en el mismo panel
    _wantMic = true;
    _scheduleRestart(const Duration(milliseconds: 300));
  }

  void _scheduleRestart(Duration delay) {
    if (_disposed || _isProcessingResponse) return;

    // Debounce para evitar ráfagas de reinicio
    _restartDebounce?.cancel();
    _restartDebounce = Timer(delay, () {
      if (_disposed || _isProcessingResponse) return;
      _beginListen();
    });
  }

  Future<void> _beginListen() async {
    if (_disposed || !_wantMic || _isProcessingResponse) return;

    // No iniciar si ya está escuchando
    if (_speechToText.isListening || _restartLock) return;

    // Gap mínimo entre inicios
    if (DateTime.now().difference(_lastListenStarted) <
        const Duration(milliseconds: 700)) {
      return;
    }

    await _checkMicrophonePermission();

    _restartLock = true;
    try {
      setState(() => _isListening = true);
      _lastListenStarted = DateTime.now();

      await _speechToText.listen(
        onResult: (result) {
          if (_disposed || _isProcessingResponse) return;

          _currentRecognizedText = result.recognizedWords;
          final words = result.recognizedWords.toUpperCase().split(' ');

          final detected = <String>[];
          for (var word in words) {
            word = word.trim();
            if (word.isEmpty) continue;

            if (_letterMapping.containsKey(word)) {
              final letter = _letterMapping[word]!;
              if (!detected.contains(letter)) detected.add(letter);
            } else if (word.length == 1 && RegExp(r'^[A-Z]$').hasMatch(word)) {
              if (!detected.contains(word)) detected.add(word);
            }
          }

          if (mounted) {
            setState(() => _recognizedWords = detected);
          }

          // Si ya hay suficientes, evaluar
          if (result.finalResult ||
              _recognizedWords.length >= _currentLetters.length) {
            if (!_isProcessingResponse) _evaluateResponse();
          }
        },
        listenFor: const Duration(minutes: 1), // dictation prolongado
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        localeId: _localeId ?? 'es_ES',
        listenMode: ListenMode.dictation,
        onSoundLevelChange: (level) {
          if (mounted) {
            setState(() => _inputLevel = level.clamp(0, 90));
          }
        },
        cancelOnError: true,
      );
    } catch (e) {
      print('Error iniciando escucha: $e');
      // Reintento suave
      _scheduleRestart(const Duration(milliseconds: 900));
    } finally {
      // Liberar el lock tras un pequeño margen
      Future.delayed(const Duration(milliseconds: 700), () {
        _restartLock = false;
      });
    }
  }

  void _stopListeningCompletely() {
    // Apaga intención de seguir escuchando
    _wantMic = false;
    _restartDebounce?.cancel();
    try {
      _speechToText.stop();
    } catch (_) {}
    if (mounted) setState(() => _isListening = false);
  }

  void _evaluateResponse() {
    if (_disposed || _isProcessingResponse) return;

    _isProcessingResponse = true;
    // Apagar mic para evaluar y evitar reentradas
    _stopListeningCompletely();

    if (mounted) {
      setState(() => _currentState = TestState.evaluating);
    }

    int correct = 0;
    final expected = List<String>.from(_currentLetters);

    for (final recognized in _recognizedWords) {
      if (expected.remove(recognized)) correct++;
    }

    final accuracy =
        _currentLetters.isEmpty ? 0.0 : correct / _currentLetters.length;
    final passed = accuracy >= 0.5;

    if (_disposed) return;

    if (passed) {
      _consecutiveErrors = 0;
      _passLevel();
    } else {
      _consecutiveErrors++;
      if (_consecutiveErrors >= 2) {
        _completeEye();
      } else {
        _retryLevel();
      }
    }
  }

  void _passLevel() {
    if (_disposed) return;
    _testResults.add('${_levels[_currentLevel].name}: APROBADO');
    _currentLevel++;
    _isProcessingResponse = false;

    // Siguiente nivel
    Future.delayed(const Duration(milliseconds: 400), () => _startLevel());
  }

  void _retryLevel() {
    if (_disposed) return;
    _isProcessingResponse = false;

    // Reintento del mismo nivel
    Future.delayed(const Duration(milliseconds: 500), () => _startLevel());
  }

  void _completeEye() {
    if (_disposed) return;

    final lastLevel =
        _currentLevel > 0 ? _levels[_currentLevel - 1].name : 'Ninguno';
    _testResults.add('Ojo $_currentEye: $lastLevel');

    if (_currentEye == 'derecho') {
      _switchToLeftEye();
    } else {
      _showFinalResults();
    }
  }

  void _switchToLeftEye() {
    if (_disposed) return;

    setState(() {
      _currentEye = 'izquierdo';
      _currentLevel = 0;
      _consecutiveErrors = 0;
      _currentState = TestState.instructions;
      _isProcessingResponse = false;
    });
  }

  void _showFinalResults() {
    if (_disposed) return;

    setState(() {
      _currentState = TestState.results;
      _isProcessingResponse = false;
    });
  }

  String _generateReport() {
    final results = <String, String>{};
    for (final r in _testResults) {
      if (r.contains('Ojo derecho:')) {
        results['derecho'] = r.split(': ')[1];
      } else if (r.contains('Ojo izquierdo:')) {
        results['izquierdo'] = r.split(': ')[1];
      }
    }

    String report = 'REPORTE DE AGUDEZA VISUAL\n\n';
    report += 'Ojo Derecho: ${results['derecho'] ?? 'No evaluado'}\n';
    report += 'Ojo Izquierdo: ${results['izquierdo'] ?? 'No evaluado'}\n\n';

    final hasGood = results.values.any(
      (r) => r.contains('20/20') || r.contains('20/25'),
    );
    final hasModerate = results.values.any(
      (r) => r.contains('20/30') || r.contains('20/40'),
    );

    if (hasGood) {
      report += 'EVALUACIÓN: Agudeza visual normal a buena\n';
    } else if (hasModerate) {
      report += 'EVALUACIÓN: Agudeza visual moderada - Revisión recomendada\n';
    } else {
      report +=
          'EVALUACIÓN: Deficiencia visual detectada - Consulta oftalmológica necesaria\n';
    }

    report += '\nEste es un tamizaje preliminar. Consulte a un especialista.';
    return report;
  }

  void _showError(String message) {
    if (_disposed || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _resetTest() {
    _stopListeningCompletely();
    setState(() {
      _currentLevel = 0;
      _currentEye = 'derecho';
      _testResults.clear();
      _consecutiveErrors = 0;
      _currentState = TestState.instructions;
      _isProcessingResponse = false;
      _recognizedWords.clear();
      _currentRecognizedText = '';
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _watchdog?.cancel();
    _restartDebounce?.cancel();
    _stopListeningCompletely();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _disposed = true;
        _watchdog?.cancel();
        _restartDebounce?.cancel();
        _stopListeningCompletely();
        return true;
      },
      child: Scaffold(
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
              _disposed = true;
              _watchdog?.cancel();
              _restartDebounce?.cancel();
              _stopListeningCompletely();
              Navigator.pop(context);
            },
          ),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentState) {
      case TestState.initializing:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 20),
              Text(
                'Inicializando reconocimiento de voz...',
                style: GoogleFonts.roboto(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        );

      case TestState.instructions:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.visibility, size: 80, color: Colors.white),
                const SizedBox(height: 30),
                Text(
                  'Test de Agudeza Visual',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'INSTRUCCIONES:',
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        '• Tápese el ojo ${_currentEye == 'derecho' ? 'izquierdo' : 'derecho'}\n'
                        '• Mantenga el teléfono a ~60cm\n'
                        '• Diga las letras que vea claramente\n'
                        '• El micrófono estará activo durante cada nivel',
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _startTest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF17635F),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'COMENZAR TEST',
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      case TestState.showingLetters:
        final pulse =
            1 + (_inputLevel / 90) * 0.25; // pulso leve con nivel de voz
        return Column(
          children: [
            Expanded(
              flex: 3,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Nivel ${_currentLevel + 1} - ${_levels[_currentLevel].name}',
                      style: GoogleFonts.roboto(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Wrap(
                      spacing: 40,
                      runSpacing: 30,
                      alignment: WrapAlignment.center,
                      children:
                          _currentLetters
                              .map(
                                (letter) => Text(
                                  letter,
                                  style: GoogleFonts.roboto(
                                    color: Colors.white,
                                    fontSize: _levels[_currentLevel].fontSize,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 8,
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),
              ),
            ),
            // Panel de micrófono integrado
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: (_isListening ? 100.0 : 80.0) * pulse,
                      height: (_isListening ? 100.0 : 80.0) * pulse,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _isListening
                                ? Colors.red.withOpacity(0.28)
                                : Colors.grey.withOpacity(0.28),
                        border: Border.all(
                          color: _isListening ? Colors.red : Colors.grey,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        Icons.mic,
                        size: _isListening ? 50 : 40,
                        color: _isListening ? Colors.red : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _isListening ? 'Escuchando...' : 'Micrófono inactivo',
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_recognizedWords.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 30),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.35),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Detectado:',
                              style: GoogleFonts.roboto(
                                color: Colors.green[300],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _recognizedWords.join(' - '),
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_currentRecognizedText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Texto: "$_currentRecognizedText"',
                          style: GoogleFonts.roboto(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            // Reinicio manual seguro
                            _wantMic = true;
                            _scheduleRestart(const Duration(milliseconds: 200));
                          },
                          icon: const Icon(Icons.mic),
                          label: const Text('Reintentar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed:
                              _recognizedWords.isNotEmpty &&
                                      !_isProcessingResponse
                                  ? _evaluateResponse
                                  : null,
                          icon: const Icon(Icons.check),
                          label: const Text('Evaluar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

      case TestState.evaluating:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 4,
              ),
              const SizedBox(height: 30),
              Text(
                'Evaluando respuesta...',
                style: GoogleFonts.roboto(color: Colors.white, fontSize: 20),
              ),
              if (_recognizedWords.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Detectadas: ${_recognizedWords.join(", ")}',
                  style: GoogleFonts.roboto(color: Colors.grey, fontSize: 16),
                ),
                Text(
                  'Esperadas: ${_currentLetters.join(", ")}',
                  style: GoogleFonts.roboto(color: Colors.grey, fontSize: 16),
                ),
              ],
            ],
          ),
        );

      case TestState.results:
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Icon(
                        Icons.assessment,
                        size: 80,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'REPORTE DE RESULTADOS',
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _resetTest,
                      icon: const Icon(Icons.refresh),
                      label: const Text('REPETIR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _disposed = true;
                        _watchdog?.cancel();
                        _restartDebounce?.cancel();
                        _stopListeningCompletely();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('FINALIZAR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF17635F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
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
}
