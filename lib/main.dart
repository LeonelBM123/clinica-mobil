import 'package:clinica_visionex/screens/AdminScreen.dart';
import 'package:clinica_visionex/screens/Login.dart';
import 'package:clinica_visionex/screens/MedicoScreen.dart';
import 'package:clinica_visionex/screens/PacienteScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(
    MaterialApp(

      supportedLocales: const [
        Locale('es', 'BO'),
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      title: 'Visionex',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Login(),
        '/AdminScreen': (context) => AdminScreen(),
        '/MedicoScreen': (context) => MedicoScreen(),
        '/PacienteScreen': (context) => PacienteScreen(),
      },
    ),
  );
}
