import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:app_clima_01/config/app_theme.dart';
import 'package:app_clima_01/firebase/conexion_firebase.dart';
import 'package:app_clima_01/views/clima/pantalla_clima.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:app_clima_01/services/push_notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Manejando mensaje en segundo plano: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_AR', null);
  await dotenv.load(fileName: ".env");
  await ServiceFirebase.inicializar();
  await PushNotificationService.inicializar();
  
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const ProviderScope(child: MiAppDeClima()));
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