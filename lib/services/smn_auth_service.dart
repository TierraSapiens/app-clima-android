import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class SmnAuthService {
  static const String _tokenUrl = 'https://ws2.smn.gob.ar/';

  // Variables estáticas para mantener el caché vivo mientras la app esté abierta
  static String? _cachedToken;
  static DateTime? _tokenFetchTime;

  Future<String?> obtenerTokenDinamico() async {
    // Si tenemos un token y pasaron menos de 10 minutos, ¡lo reutilizamos!
    if (_cachedToken != null && _tokenFetchTime != null) {
      final diferencia = DateTime.now().difference(_tokenFetchTime!);
      if (diferencia.inMinutes < 10) {
        return _cachedToken;
      }
    }

    try {
      debugPrint('Conectando a $_tokenUrl para buscar un token fresco...');
      final url = Uri.parse(_tokenUrl);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final html = response.body;
        final regExp = RegExp(
          r'''localStorage\.setItem\(['"]token['"]\s*,\s*['"]([^'"]+)['"]\)''',
        );
        final match = regExp.firstMatch(html);

        if (match != null && match.groupCount >= 1) {
          _cachedToken = match.group(1);
          _tokenFetchTime = DateTime.now(); // Guardamos la hora de creación
          debugPrint(
            '¡Token interceptado y guardado en CACHÉ! (Longitud: ${_cachedToken?.length})',
          );
          return _cachedToken;
        } else {
          debugPrint(
            '❌ Alerta: Se leyó la web del SMN pero no se encontró el patrón.',
          );
        }
      } else {
        debugPrint('❌ Error de servidor: Código ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error crítico de red al buscar el token: $e');
    }
    return null;
  }
}
