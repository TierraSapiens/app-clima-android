import 'package:flutter/material.dart';

class PantallaAvisos extends StatelessWidget {
  const PantallaAvisos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Avisos Meteorológicos'),
        backgroundColor: const Color(0xFFE65100),
      ),
      body: const Center(
        child: Text(
          'Próximamente: Información de Avisos a Corto Plazo',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
    );
  }
}