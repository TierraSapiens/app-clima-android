import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class SmnAuthService {
  static const String _tokenUrl = 'https://ws2.smn.gob.ar/';

  Future<String?> obtenerTokenDinamico() async {
    try {
      debugPrint('Conectando a $_tokenUrl para buscar un token fresco...');
      
      final url = Uri.parse(_tokenUrl);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final html = response.body;
        final regExp = RegExp(r'''localStorage\.setItem\(['"]token['"]\s*,\s*['"]([^'"]+)['"]\)''');
        final match = regExp.firstMatch(html);

        if (match != null && match.groupCount >= 1) {
          final token = match.group(1);
          debugPrint('¡Token del SMN interceptado con éxito! (Longitud: ${token?.length})');
          return token;
        } else {
          debugPrint('❌ Alerta: Se leyó la web del SMN pero no se encontró el patrón del token en el JavaScript.');
        }
      } else {
        debugPrint('❌ Error de servidor: El SMN respondió con código ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error crítico de red al intentar buscar el token: $e');
    }
    
    return null;
  }
}