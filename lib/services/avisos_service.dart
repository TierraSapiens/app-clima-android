import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'smn_auth_service.dart';

class AvisosService {
  final SmnAuthService _authService = SmnAuthService();

  static const String _apiBaseUrl = 'https://ws1.smn.gob.ar/v1/warning/shortterm/';

  Future<List<dynamic>> fetchAvisosReales() async {
    try {
      final token = await _authService.obtenerTokenDinamico();
      
      if (token == null) {
        debugPrint('❌ AvisosService: No se puede hacer la petición porque no se obtuvo un token válido.');
        return [];
      }

      final urlCompleta = Uri.parse(_apiBaseUrl);
      debugPrint('🚀 Conectando a la API de Avisos Corto Plazo: $urlCompleta');

      final response = await http.get(
        urlCompleta,
        headers: {
          'Authorization': 'JWT $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        debugPrint('====== DIAGNÓSTICO SMN AVISOS ======');
        debugPrint('1. ¿Llegó respuesta del body?: ${response.body.isNotEmpty}');
        debugPrint('2. Contenido crudo de Avisos: ${response.body}');
        debugPrint('====================================');

        if (response.body.isEmpty) return [];

        final dynamic dataJson = json.decode(response.body);

        if (dataJson is List) {
          return dataJson;
        } else if (dataJson is Map && dataJson.containsKey('features')) {
          return dataJson['features'] as List<dynamic>;
        }
        
        return [];
      } else if (response.statusCode == 401) {
        debugPrint('❌ AvisosService (401): El token fue rechazado por el SMN.');
      } else {
        debugPrint('❌ AvisosService: Error de respuesta. Código: ${response.statusCode}');
      }

    } catch (e) {
      debugPrint('❌ Error crítico en AvisosService al traer datos reales: $e');
    }
    return [];
  }
}