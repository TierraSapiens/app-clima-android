import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ServiceFirebase {
  static Future<void> inicializar() async {
    try {
      await Firebase.initializeApp();

      FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);

      await messaging.subscribeToTopic('alerta_mardelplata');
      debugPrint(
        '📡 MeteoMarti sintonizó con éxito el canal: alerta_mardelplata',
      );
    } catch (e) {
      debugPrint('❌ Error al encender Firebase: $e');
    }
  }
}
