import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/alerta_model.dart';
import '../../services/alertas_service.dart';

// El proveedor que va a escuchar nuestra pantalla de alertas
final alertasControllerProvider = AsyncNotifierProvider<PantallaAlertasController, List<AlertaZona>>(() {
  return PantallaAlertasController();
});

class PantallaAlertasController extends AsyncNotifier<List<AlertaZona>> {
  @override
  Future<List<AlertaZona>> build() async {
    return _cargarTodaLaData();
  }

  // Función interna que hace el trabajo pesado
  Future<List<AlertaZona>> _cargarTodaLaData() async {
    // 1. Cargamos el molde geográfico de los assets
    final String geojsonString = await rootBundle.loadString('assets/geo/areas.geojson');
    final Map<String, dynamic> geojsonData = json.decode(geojsonString);
    final List<dynamic> features = geojsonData['features'];

    // 2. Traemos las alertas vivas del SMN de internet
    final List<dynamic> datosSmn = await AlertaService.fetchAlertas();

    // 3. Fusionamos ambos usando el servicio de la Fase 1
    return AlertaService.procesarAlertas(features, datosSmn);
  }

  // Función mágica para actualizar cuando el usuario quiera o cuando volvamos a la app
  Future<void> refrescarAlertas() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _cargarTodaLaData());
  }
}