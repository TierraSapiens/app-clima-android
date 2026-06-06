import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/aviso_model.dart';
import '../../services/avisos_service.dart';
import 'dart:developer' as developer;

final avisosControllerProvider = AsyncNotifierProvider<PantallaAvisosController, List<AvisoCortoPlazo>>(() {
  return PantallaAvisosController();
});

class PantallaAvisosController extends AsyncNotifier<List<AvisoCortoPlazo>> {
  final AvisosService _avisosService = AvisosService();

  @override
  Future<List<AvisoCortoPlazo>> build() async {
    return _cargarTodaLaData();
  }

  Future<List<AvisoCortoPlazo>> _cargarTodaLaData() async {
    try {
      final List<dynamic> featuresCrudas = await _avisosService.fetchAvisosReales();
      final List<AvisoCortoPlazo> avisosProcesados = featuresCrudas.map((feature) {
        return AvisoCortoPlazo.fromGeoJson(feature as Map<String, dynamic>);
      }).toList();

      final avisosValidos = avisosProcesados.where((aviso) => aviso.coordenadas.isNotEmpty).toList();

      developer.log(
        "📦 Avisos a muy corto plazo procesados con éxito. Cantidad activa: ${avisosValidos.length}",
        name: 'ClimApp',
      );

      return avisosValidos;
    } catch (e, st) {
      developer.log(
        "Servidor SMN (shortterm) caído o sin red. Activando modo seguro local.",
        name: 'ClimApp',
        error: e,
        stackTrace: st,
      );
      return [];
    }
  }

  Future<void> refrescarAvisos() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _cargarTodaLaData());
  }
}