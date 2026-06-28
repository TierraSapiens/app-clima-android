import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/push_notification_service.dart';
import '../../models/configuracion_model.dart';
import '../../services/preferencias_service.dart';

// 1. Usamos NotifierProvider en lugar de StateNotifierProvider
final configuracionProvider = NotifierProvider<ConfiguracionController, ConfiguracionModel>(() {
  return ConfiguracionController();
});

// 2. Ahora heredamos simplemente de Notifier
class ConfiguracionController extends Notifier<ConfiguracionModel> {
  final PreferenciasService _preferenciasService = PreferenciasService();

  // 3. En el Riverpod moderno, el estado inicial se define obligatoriamente en este método build()
  @override
  ConfiguracionModel build() {
    // Lanzamos la carga de preferencias en segundo plano
    cargarPreferencias();
    
    // Retornamos un modelo por defecto inmediatamente para que la pantalla no se quede vacía
    return ConfiguracionModel();
  }

  Future<void> cargarPreferencias() async {
    final configGuardada = await _preferenciasService.cargarConfiguracion();
    state = configGuardada; // ¡Magia! Al pisar 'state', la pantalla se actualiza sola
  }

  Future<void> actualizarTemperatura(String nuevaUnidad) async {
    state = state.copyWith(unidadTemperatura: nuevaUnidad);
    await _preferenciasService.guardarConfiguracion(state);
  }

  Future<void> actualizarViento(String nuevaUnidad) async {
    state = state.copyWith(unidadViento: nuevaUnidad);
    await _preferenciasService.guardarConfiguracion(state);
  }

  Future<void> actualizarPrecipitacion(String nuevaUnidad) async {
    state = state.copyWith(unidadPrecipitacion: nuevaUnidad);
    await _preferenciasService.guardarConfiguracion(state);
  }

  Future<void> actualizarPresion(String nuevaUnidad) async {
    state = state.copyWith(unidadPresion: nuevaUnidad);
    await _preferenciasService.guardarConfiguracion(state);
  }

  Future<void> actualizarAlertasLocales(bool activas) async {
    state = state.copyWith(alertasLocalesActivas: activas);
    await _preferenciasService.guardarConfiguracion(state);

    if (activas) {
      await PushNotificationService.activarAlertas();
    } else {
      await PushNotificationService.desactivarAlertas();
    }
  }
}