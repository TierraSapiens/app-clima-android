import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/configuracion_model.dart';

class PreferenciasService {
  static const String _keyConfiguracion = 'climapp_config_user';
  Future<void> guardarConfiguracion(ConfiguracionModel configuracion) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = json.encode(configuracion.toMap());
      await prefs.setString(_keyConfiguracion, jsonString);
    } catch (e) {
      debugPrint('Error al guardar las preferencias: $e');
    }
  }

  Future<ConfiguracionModel> cargarConfiguracion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_keyConfiguracion);
      if (jsonString != null) {
        final Map<String, dynamic> mapa = json.decode(jsonString);
        return ConfiguracionModel.fromMap(mapa);
      }
    } catch (e) {
      debugPrint('Error al cargar las preferencias (se usarán por defecto): $e');
    }
    return ConfiguracionModel();
  }
}