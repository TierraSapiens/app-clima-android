import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/alerta_model.dart';
import 'package:flutter/foundation.dart';

class AlertaService {
  // Esta es la URL que encontraste (reemplázala por la real)
  static const String urlSmn = 'AQUI_VA_LA_URL_DEL_JSON_DEL_SMN';

  // 1. EL "FETCH": Salimos a buscar los datos a internet
  static Future<List<dynamic>> fetchAlertas() async {
    try {
      final response = await http.get(Uri.parse(urlSmn));
      
      if (response.statusCode == 200) {
        return json.decode(response.body); // Regresa la lista de objetos de la API
      } else {
        throw Exception('Error al conectar con el servidor del SMN');
      }
    } catch (e) {
      debugPrint("Error: $e");
      return []; // Retornamos lista vacía si hay error
    }
  }

  // 2. LA "FUSIÓN": La lógica que ya teníamos, ahora unida al proceso
  static List<AlertaZona> procesarAlertas(List<dynamic> features, List<dynamic> datosSmn) {
    List<AlertaZona> listaFinal = [];

    for (var feature in features) {
      int gid = feature['properties']['gid'];
      
      var data = datosSmn.firstWhere(
        (item) => item['area_id'] == gid, 
        orElse: () => null
      );

      int nivel = 0;
      if (data != null && data['warnings'] != null && (data['warnings'] as List).isNotEmpty) {
        nivel = data['warnings'][0]['max_level'] ?? 0;
      }

      listaFinal.add(AlertaZona(
        gid: gid,
        maxLevel: nivel,
        coordenadas: feature['geometry']['coordinates'],
      ));
    }
    return listaFinal;
  }
}