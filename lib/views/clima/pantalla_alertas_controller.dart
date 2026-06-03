import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/alerta_model.dart';
import '../../services/alertas_service.dart';
import 'dart:developer' as developer;

final diaSeleccionadoProvider = NotifierProvider<DiaSeleccionadoNotifier, int>(() {
  return DiaSeleccionadoNotifier();
});

class DiaSeleccionadoNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void cambiarDia(int nuevoIndex) {
    state = nuevoIndex;
  }
}

final alertasControllerProvider = AsyncNotifierProvider<PantallaAlertasController, List<AlertaZona>>(() {
  return PantallaAlertasController();
});

class PantallaAlertasController extends AsyncNotifier<List<AlertaZona>> {
  
  @override
  Future<List<AlertaZona>> build() async {
    final indexDia = ref.watch(diaSeleccionadoProvider);
    final fechaDestino = DateTime.now().add(Duration(days: indexDia));
    return _cargarTodaLaData(fechaDestino);
  }

  Future<List<AlertaZona>> _cargarTodaLaData(DateTime fecha) async {
    final String geojsonString = await rootBundle.loadString('assets/geo/areas.geojson');
    final Map<String, dynamic> geojsonData = json.decode(geojsonString);
    final List<dynamic> features = geojsonData['features'];
    
    final alertasServiceInstance = AlertasService();
    
    try {
      final List<dynamic> datosSmn = await alertasServiceInstance.fetchAlertasReales(fecha: fecha);
      return alertasServiceInstance.procesarAlertas(features, datosSmn);
    } catch (e) {
      developer.log(
        "Servidor SMN caído o sin red. Activando modo seguro local.",
        name: 'ClimApp',
        error: e,
      );
      return alertasServiceInstance.procesarAlertas(features, []);
    }
  }

  void seleccionarDia(int index) {
    ref.read(diaSeleccionadoProvider.notifier).cambiarDia(index);
  }

  Future<void> refrescarAlertas() async {
    state = const AsyncValue.loading();
    final indexDia = ref.read(diaSeleccionadoProvider); // 👈 ¡Corregido acá perfectamente!
    final fechaDestino = DateTime.now().add(Duration(days: indexDia));
    state = await AsyncValue.guard(() => _cargarTodaLaData(fechaDestino));
  }
}

/// 📡 PROVIDER GLOBAL PARA EL BANNER DE LA PANTALLA PRINCIPAL
/// Revisa los 3 días en segundo plano y avisa si hay peligro inminente (maxLevel > 1)
final tieneAlertasActivasCualquierDiaProvider = FutureProvider<bool>((ref) async {
  final String geojsonString = await rootBundle.loadString('assets/geo/areas.geojson');
  final Map<String, dynamic> geojsonData = json.decode(geojsonString);
  final List<dynamic> features = geojsonData['features'];
  final alertasServiceInstance = AlertasService();

  for (int i = 0; i < 3; i++) {
    try {
      final fecha = DateTime.now().add(Duration(days: i));
      final List<dynamic> datosSmn = await alertasServiceInstance.fetchAlertasReales(fecha: fecha);
      final List<AlertaZona> zonasProcesadas = alertasServiceInstance.procesarAlertas(features, datosSmn);
      
      final hayAlertaReal = zonasProcesadas.any((zona) => zona.maxLevel > 1);
      if (hayAlertaReal) {
        return true; 
      }
    } catch (e) {
      developer.log("Error silencioso escaneando alertas del día $i para el banner", error: e);
    }
  }
  return false; 
});
/// 📍 PROVIDER LOCAL INTELIGENTE
/// Recibe las coordenadas de la ciudad actual y dice qué nivel de alerta real tiene (1 = Verde/Normal, 2 = Amarillo, etc.)
final nivelAlertaLocalProvider = FutureProvider.family<int, LatLng>((ref, coordenadasCiudad) async {
  final String geojsonString = await rootBundle.loadString('assets/geo/areas.geojson');
  final Map<String, dynamic> geojsonData = json.decode(geojsonString);
  final List<dynamic> features = geojsonData['features'];
  final alertasServiceInstance = AlertasService();

  int maxNivelLocal = 1; // Por defecto es 1 (Verde / Todo normal)

  // Escaneamos los 3 días en segundo plano para esta ciudad específica
  for (int i = 0; i < 3; i++) {
    try {
      final fecha = DateTime.now().add(Duration(days: i));
      final List<dynamic> datosSmn = await alertasServiceInstance.fetchAlertasReales(fecha: fecha);
      final List<AlertaZona> zonasProcesadas = alertasServiceInstance.procesarAlertas(features, datosSmn);
      
      // Buscamos si las coordenadas de la ciudad caen dentro de alguna zona con alerta activa
      for (final zona in zonasProcesadas) {
        if (zona.maxLevel > maxNivelLocal) {
          if (_isPointInPolygon(coordenadasCiudad, List<LatLng>.from(zona.coordenadas))) {
            maxNivelLocal = zona.maxLevel; // Encontró alerta en tu ciudad, actualiza el nivel máximo
          }
        }
      }
    } catch (e) {
      developer.log("Error silencioso escaneando alerta local del día $i", error: e);
    }
  }
  return maxNivelLocal; 
});

/// 🏹 ALGORITMO RAY-CASTING (Punto en Polígono)
/// Verifica matemáticamente si un punto (Lat/Lon) está atrapado dentro de una figura geométrica
bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
  int i;
  int j = polygon.length - 1;
  bool inPoly = false;

  for (i = 0; i < polygon.length; i++) {
    if ((polygon[i].longitude < point.longitude && polygon[j].longitude >= point.longitude ||
         polygon[j].longitude < point.longitude && polygon[i].longitude >= point.longitude) &&
        (polygon[i].latitude + (point.longitude - polygon[i].longitude) /
         (polygon[j].longitude - polygon[i].longitude) * (polygon[j].latitude - polygon[i].latitude) < point.latitude)) {
      inPoly = !inPoly;
    }
    j = i;
  }
  return inPoly;
}