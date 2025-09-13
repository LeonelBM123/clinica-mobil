import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login'),),
      body: IconButton(onPressed: ()=>{Navigator.pushNamed(context, '/detalle')}, icon: Icon(Icons.admin_panel_settings,color: Colors.blue,)),
    );
  }
}