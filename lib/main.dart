//import 'package:clinica_visionex/screens/AdminScreen.dart';
import 'package:clinica_visionex/screens/Login.dart';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Solo inicializar Stripe si NO es web
  if (!kIsWeb) {
    Stripe.publishableKey =
        "pk_test_51SCkj7AATixhi4DNPBftvpFp6qc9gVJisvftaQbuIHVvu0TAIrOILEjHgGFPKvPJuDOV8lBN6WUQ4z4T8IHnP2Ay00W4rxAFCR";
  }

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Visionex',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Login(),
        // PacienteScreen ya no se define aquí porque requiere parámetros
        // Se navega directamente desde Login usando Navigator.pushReplacement
      },
    ),
  );
}
