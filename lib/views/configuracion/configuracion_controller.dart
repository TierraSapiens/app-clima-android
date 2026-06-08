import 'package:flutter/material.dart';
import '../../services/push_notification_service.dart';
import '../../models/configuracion_model.dart';
import '../../services/preferencias_service.dart';

class ConfiguracionController extends ChangeNotifier {
  final PreferenciasService _preferenciasService = PreferenciasService();

  ConfiguracionModel _configuracion = ConfiguracionModel();
  bool _cargando = true;
  
  ConfiguracionModel get configuracion => _configuracion;
  bool get cargando => _cargando;
  
  ConfiguracionController() {
    cargarPreferencias();
  }

  Future<void> cargarPreferencias() async {
    _cargando = true;
    notifyListeners();
    _configuracion = await _preferenciasService.cargarConfiguracion();
    _cargando = false;
    notifyListeners();
  }

  Future<void> actualizarTemperatura(String nuevaUnidad) async {
    _configuracion = _configuracion.copyWith(unidadTemperatura: nuevaUnidad);
    notifyListeners();
    await _preferenciasService.guardarConfiguracion(_configuracion);
  }

  Future<void> actualizarViento(String nuevaUnidad) async {
    _configuracion = _configuracion.copyWith(unidadViento: nuevaUnidad);
    notifyListeners();
    await _preferenciasService.guardarConfiguracion(_configuracion);
  }

  Future<void> actualizarPrecipitacion(String nuevaUnidad) async {
    _configuracion = _configuracion.copyWith(unidadPrecipitacion: nuevaUnidad);
    notifyListeners();
    await _preferenciasService.guardarConfiguracion(_configuracion);
  }

  Future<void> actualizarPresion(String nuevaUnidad) async {
    _configuracion = _configuracion.copyWith(unidadPresion: nuevaUnidad);
    notifyListeners();
    await _preferenciasService.guardarConfiguracion(_configuracion);
  }

  Future<void> actualizarAlertasLocales(bool activas) async {
    _configuracion = _configuracion.copyWith(alertasLocalesActivas: activas);
    notifyListeners();
    await _preferenciasService.guardarConfiguracion(_configuracion);

    if (activas) {
      await PushNotificationService.activarAlertas();
    } else {
      await PushNotificationService.desactivarAlertas();
    }
  }
}