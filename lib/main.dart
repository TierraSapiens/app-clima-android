import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:app_clima_01/config/app_theme.dart';
import 'package:app_clima_01/firebase/conexion_firebase.dart';
import 'package:app_clima_01/views/clima/pantalla_clima.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_AR', null);
  runApp(const ProviderScope(child: MiAppDeClima()));
}

class MiAppDeClima extends StatelessWidget {
  const MiAppDeClima({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashInicial(),
    );
  }
}

class SplashInicial extends StatelessWidget {
  const SplashInicial({super.key});

  Future<void> _inicializar() async {
    try {
      await ServiceFirebase.inicializar();
    } catch (e) {
      debugPrint('Error inicializando Firebase: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _inicializar(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return const PantallaClima();
      },
    );
  }
}
