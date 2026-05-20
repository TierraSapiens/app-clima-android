import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; 
// Herramientas de Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:app_clima_01/screens/pantalla_clima.dart';
void main() async {
  // Asegura que Flutter esté bien despierto antes de tocar las raíces nativas
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_AR', null);

  // Inicialización inteligente de Firebase
  try {
    await Firebase.initializeApp();

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    
    // Pide permiso formal al usuario
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Sintoniza el canal de Mar del Plata
    await messaging.subscribeToTopic('alerta_mardelplata');
    debugPrint("📡 MeteoMarti sintonizó con éxito el canal: alerta_mardelplata");
  } catch (e) {
    debugPrint("❌ Error al encender Firebase: $e");
  }

  runApp(const MiAppDeClima());
}

class MiAppDeClima extends StatelessWidget {
  const MiAppDeClima({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const PantallaClima(), // <-- Esto va a marcar error en rojo por ahora, es normal
    );
  }
}