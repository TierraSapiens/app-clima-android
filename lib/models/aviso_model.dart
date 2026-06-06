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

  factory AvisoCortoPlazo.fromGeoJson(Map<String, dynamic> feature) {
    final properties = feature['properties'] ?? {};
    final geometry = feature['geometry'] ?? {};
    final String idStr = (properties['id'] ?? properties['id_aviso'] ?? properties['pk'] ?? '').toString();
    final String titleStr = (properties['title'] ?? properties['titulo'] ?? properties['name'] ?? 'Aviso a Corto Plazo').toString();
    final String descStr = (properties['description'] ?? properties['descripcion'] ?? properties['texto'] ?? '').toString();
    final String emissionStr = (properties['date'] ?? properties['fecha'] ?? properties['start'] ?? '').toString();
    final String expiryStr = (properties['expires'] ?? properties['vencimiento'] ?? properties['end'] ?? '').toString();

    List<LatLng> puntosDePoligono = [];
    try {
      final String type = (geometry['type'] ?? '').toString();
      
      if (type == 'Polygon' && geometry['coordinates'] != null) {
        final coords = geometry['coordinates'][0] as List<dynamic>;
        for (var coord in coords) {
          puntosDePoligono.add(LatLng(coord[1].toDouble(), coord[0].toDouble()));
        }
      } else if (type == 'MultiPolygon' && geometry['coordinates'] != null) {
        final coords = geometry['coordinates'][0][0] as List<dynamic>;
        for (var coord in coords) {
          puntosDePoligono.add(LatLng(coord[1].toDouble(), coord[0].toDouble()));
        }
      }
    } catch (e) {
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