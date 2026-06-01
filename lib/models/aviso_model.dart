import 'package:latlong2/latlong.dart';

class AvisoCortoPlazo {
  final String id;
  final String titulo;
  final String descripcion;
  final String fechaEmision;
  final String fechaVencimiento;
  final List<LatLng> coordenadas;

  AvisoCortoPlazo({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fechaEmision,
    required this.fechaVencimiento,
    required this.coordenadas,
  });

  /// Factory para construir un Aviso a Corto Plazo de forma segura
  /// a partir de una 'Feature' individual del GeoJSON interactivo del SMN.
  factory AvisoCortoPlazo.fromGeoJson(Map<String, dynamic> feature) {
    final properties = feature['properties'] ?? {};
    final geometry = feature['geometry'] ?? {};

    // 🛡️ Extracción defensiva de textos probando variantes típicas del SMN
    final String idStr = (properties['id'] ?? properties['id_aviso'] ?? properties['pk'] ?? '').toString();
    final String titleStr = (properties['title'] ?? properties['titulo'] ?? properties['name'] ?? 'Aviso a Corto Plazo').toString();
    final String descStr = (properties['description'] ?? properties['descripcion'] ?? properties['texto'] ?? '').toString();
    final String emissionStr = (properties['date'] ?? properties['fecha'] ?? properties['start'] ?? '').toString();
    final String expiryStr = (properties['expires'] ?? properties['vencimiento'] ?? properties['end'] ?? '').toString();

    // 🗺️ Parseo geométrico del polígono de la tormenta (siguiendo tu lógica probada de alertas)
    List<LatLng> puntosDePoligono = [];
    try {
      final String type = (geometry['type'] ?? '').toString();
      
      if (type == 'Polygon' && geometry['coordinates'] != null) {
        final coords = geometry['coordinates'][0] as List<dynamic>;
        for (var coord in coords) {
          puntosDePoligono.add(LatLng(coord[1].toDouble(), coord[0].toDouble()));
        }
      } else if (type == 'MultiPolygon' && geometry['coordinates'] != null) {
        // En MultiPolygon extraemos el primer anillo del primer polígono base
        final coords = geometry['coordinates'][0][0] as List<dynamic>;
        for (var coord in coords) {
          puntosDePoligono.add(LatLng(coord[1].toDouble(), coord[0].toDouble()));
        }
      }
    } catch (e) {
      // Si un polígono viene corrupto de origen, evitamos que rompa el renderizado de la app
      puntosDePoligono = [];
    }

    return AvisoCortoPlazo(
      id: idStr,
      titulo: titleStr,
      descripcion: descStr,
      fechaEmision: emissionStr,
      fechaVencimiento: expiryStr,
      coordenadas: puntosDePoligono,
    );
  }
}