import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:app_clima_01/config/app_theme.dart';
import 'package:app_clima_01/firebase/conexion_firebase.dart';
import 'package:app_clima_01/screens/pantalla_clima.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_AR', null);

  await ServiceFirebase.inicializar();

  runApp(const MiAppDeClima());
}

class MiAppDeClima extends StatelessWidget {
  const MiAppDeClima({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const PantallaClima(),
    );
  }
}