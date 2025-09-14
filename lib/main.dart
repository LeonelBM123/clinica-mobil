import 'package:clinica_visionex/screens/AdminScreen.dart';
import 'package:clinica_visionex/screens/Login.dart';
import 'package:clinica_visionex/screens/MedicoScreen.dart';
import 'package:clinica_visionex/screens/PacienteScreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Clinica Visionex',
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
    initialRoute: '/',
    routes: {
      '/': (context) => Login(),
      '/AdminScreen': (context) => AdminScreen(),
      '/MedicoScreen': (context) => MedicoScreen(),
      '/PacienteScreen': (context) => PacienteScreen(),
    },
  ));
}