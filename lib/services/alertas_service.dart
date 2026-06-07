import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/alerta_model.dart';
import 'smn_auth_service.dart';

class AlertasService {
  final SmnAuthService _authService = SmnAuthService();
  static const String _apiBaseUrl = 'https://ws1.smn.gob.ar/v1/warning/alert/area';

  // 📅 Ahora acepta una fecha opcional. Si no se la pasamos, por defecto busca 'hoy'.
  Future<List<dynamic>> fetchAlertasReales({DateTime? fecha}) async {
    try {
      final token = await _authService.obtenerTokenDinamico();
      
      if (token == null) {
        debugPrint('❌ AlertasService: No se puede hacer la petición porque no se obtuvo un token válido.');
        return [];
      }

      // Si viene una fecha la usa, sino usa la hora actual del dispositivo
      final ahora = fecha ?? DateTime.now();
      final anio = ahora.year.toString();
      final mes = ahora.month.toString().padLeft(2, '0');
      final dia = ahora.day.toString().padLeft(2, '0');
      
      final fechaFormateada = '$anio-$mes-$dia';
      debugPrint('Fecha calculada para la API: $fechaFormateada');

      final urlCompleta = Uri.parse(
        '$_apiBaseUrl?mode=alert&date=$fechaFormateada&compact=true'
      );

      debugPrint('Conectando a la API del SMN: $urlCompleta');

      final response = await http.get(
        urlCompleta,
        headers: {
          'Authorization': 'JWT $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        debugPrint('====== DIAGNÓSTICO SMN ======');
        debugPrint('1. ¿Llegó respuesta del body?: ${response.body.isNotEmpty}');
        debugPrint('2. Contenido crudo del JSON del SMN:');
        debugPrint(response.body); 
        debugPrint('==============================');

        final List<dynamic> dataJson = json.decode(response.body);
        debugPrint('📦 Cantidad de registros de alerta recibidos: ${dataJson.length}');
        return dataJson;

      } else if (response.statusCode == 401) {
        debugPrint('❌ Error de Autenticación (401): El token fue rechazado por el SMN.');
      } else {
        debugPrint('❌ Error de respuesta del SMN. Código: ${response.statusCode} - Body: ${response.body}');
      }

    } catch (e) {
      debugPrint('❌ Error crítico en AlertasService al traer datos reales: $e');
    }
    return [];
  }

  List<AlertaZona> procesarAlertas(List<dynamic> features, List<dynamic> datosSmn) {
    debugPrint('🔄 Fusionando ${features.length} zonas geométricas con ${datosSmn.length} alertas vivas...');
    
    List<AlertaZona> zonasProcesadas = [];

    for (var feature in features) {
      final properties = feature['properties'] ?? {};
      final geometry = feature['geometry'] ?? {};
  
      final String idZonaGeoStr = (properties['id'] ?? properties['id_zona'] ?? properties['OBJECTID'] ?? properties['gid'] ?? '').toString();
      if (idZonaGeoStr.isEmpty) continue;

      final alertaSmn = datosSmn.firstWhere(
        (alerta) => (alerta['area_id'] ?? '').toString() == idZonaGeoStr,
        orElse: () => null,
      );

      int nivelAlerta = 0;
      if (alertaSmn != null && alertaSmn['warnings'] != null && (alertaSmn['warnings'] as List).isNotEmpty) {
        nivelAlerta = alertaSmn['warnings'][0]['max_level'] ?? 0;
      }

      List<LatLng> puntosDePoligono = [];
      try {
        if (geometry['type'] == 'Polygon') {
          final coords = geometry['coordinates'][0] as List<dynamic>;
          for (var coord in coords) {
            puntosDePoligono.add(LatLng(coord[1].toDouble(), coord[0].toDouble()));
          }
        } else if (geometry['type'] == 'MultiPolygon') {
          final coords = geometry['coordinates'][0][0] as List<dynamic>;
          for (var coord in coords) {
            puntosDePoligono.add(LatLng(coord[1].toDouble(), coord[0].toDouble()));
          }
        }
      } catch (e) {
        debugPrint('Error parseando geometría de zona $idZonaGeoStr: $e');
        continue;
      }

      if (puntosDePoligono.isNotEmpty) {
        zonasProcesadas.add(
          AlertaZona(
            gid: int.tryParse(idZonaGeoStr) ?? 0,
            maxLevel: nivelAlerta,
            coordenadas: puntosDePoligono,
          ),
        );
      }
    }
    return zonasProcesadas;
  }
}