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