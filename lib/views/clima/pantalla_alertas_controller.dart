import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/alerta_model.dart';
import '../../services/alertas_service.dart';

// 📅 Reemplazamos StateProvider por un Notifier moderno de Riverpod 2.x
// Al heredar de Notifier<int>, exponemos un entero de forma ultra segura.
final diaSeleccionadoProvider = NotifierProvider<DiaSeleccionadoNotifier, int>(() {
  return DiaSeleccionadoNotifier();
});

class DiaSeleccionadoNotifier extends Notifier<int> {
  @override
  int build() => 0; // El estado inicial siempre es 0 (Hoy)

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
    // 🔄 Seguimos escuchando reactivamente el cambio de día
    final indexDia = ref.watch(diaSeleccionadoProvider);
    
    final fechaDestino = DateTime.now().add(Duration(days: indexDia));
    return _cargarTodaLaData(fechaDestino);
  }

  Future<List<AlertaZona>> _cargarTodaLaData(DateTime fecha) async {
    final String geojsonString = await rootBundle.loadString('assets/geo/areas.geojson');
    final Map<String, dynamic> geojsonData = json.decode(geojsonString);
    final List<dynamic> features = geojsonData['features'];
    
    final alertasServiceInstance = AlertasService();
    final List<dynamic> datosSmn = await alertasServiceInstance.fetchAlertasReales(fecha: fecha);
    
    return alertasServiceInstance.procesarAlertas(features, datosSmn);
  }

  // Esta función encapsula el cambio para que tu vista no tenga que cambiar nada
  void seleccionarDia(int index) {
    ref.read(diaSeleccionadoProvider.notifier).cambiarDia(index);
  }

  Future<void> refrescarAlertas() async {
    state = const AsyncValue.loading();
    final indexDia = ref.read(diaSeleccionadoProvider);
    final fechaDestino = DateTime.now().add(Duration(days: indexDia));
    state = await AsyncValue.guard(() => _cargarTodaLaData(fechaDestino));
  }
}