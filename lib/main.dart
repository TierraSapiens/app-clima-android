import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Importamos Riverpod
import 'package:app_clima_01/views/clima/pantalla_clima.dart';

void main() {
  runApp(
    // 2. Envolvemos TODA la app dentro de ProviderScope
    const ProviderScope(
      child: MyWeatherApp(),
    ),
  );
}

class MyWeatherApp extends StatelessWidget {
  const MyWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Clima',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(), // O tu configuración de AppTheme existente
      home: const PantallaClima(),
    );
  }
}