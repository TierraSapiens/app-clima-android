import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/advertencia_model.dart';
import 'smn_auth_service.dart';

class AdvertenciasService {
  final SmnAuthService _authService = SmnAuthService();
  static const String _apiBaseUrl =
      'https://ws1.smn.gob.ar/v1/warning/advertence';

  Future<List<AdvertenciaModel>> fetchAdvertenciasActuales() async {
    try {
      final token = await _authService.obtenerTokenDinamico();
      if (token == null) return [];

      final urlCompleta = Uri.parse(_apiBaseUrl);
      final response = await http.get(
        urlCompleta,
        headers: {'Authorization': 'JWT $token', 'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> dataJson = json.decode(response.body);

        if (dataJson.isEmpty) return [];

        debugPrint('====== ¡HAY ADVERTENCIAS ACTIVAS! ======');
        debugPrint(response.body);
        debugPrint('========================================');

        // Mapeamos dinámicamente la lista de advertencias
        return dataJson.map((item) {
          return AdvertenciaModel(
            titulo: item['title'] ?? item['phenomenon'] ?? 'Advertencia',
            descripcion:
                item['description'] ??
                item['text'] ??
                'Se esperan fenómenos en la región.',
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('❌ Error en AdvertenciasService: $e');
    }
    return []; // Retorna lista vacía ante fallos (actúa como Tranquilidad)
  }
}
