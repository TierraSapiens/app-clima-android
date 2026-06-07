import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class PushNotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> inicializar() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('Permiso de notificaciones: ${settings.authorizationStatus}');
  }

  static Future<void> activarAlertas() async {
    try {
      await _firebaseMessaging.subscribeToTopic('alertas_clima');
      debugPrint('✅ Celular SUSCRITO a las alertas climáticas');
    } catch (e) {
      debugPrint('❌ Error al suscribir: $e');
    }
  }

  static Future<void> desactivarAlertas() async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic('alertas_clima');
      debugPrint('🔕 Celular DESUSCRITO de las alertas climáticas');
    } catch (e) {
      debugPrint('❌ Error al desuscribir: $e');
    }
  }
}