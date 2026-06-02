import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/aviso_model.dart';
import '../../services/avisos_service.dart';
import 'dart:developer' as developer;

// 📡 Provider global e independiente, respetando tu patrón de instanciación manual
final avisosControllerProvider = AsyncNotifierProvider<PantallaAvisosController, List<AvisoCortoPlazo>>(() {
  return PantallaAvisosController();
});

class PantallaAvisosController extends AsyncNotifier<List<AvisoCortoPlazo>> {
  final AvisosService _avisosService = AvisosService();

  @override
  Future<List<AvisoCortoPlazo>> build() async {
    // Al inicializarse por primera vez el proveedor, carga inmediatamente la data actual
    return _cargarTodaLaData();
  }

  /// Método privado centralizado para obtener y mapear la información del SMN
  Future<List<AvisoCortoPlazo>> _cargarTodaLaData() async {
    try {
      // 1. Buscamos los datos crudos desde el endpoint 'shortterm/' del SMN
      final List<dynamic> featuresCrudas = await _avisosService.fetchAvisosReales();
      
      // 2. Mapeamos cada feature geométrico de internet a nuestro modelo seguro
      final List<AvisoCortoPlazo> avisosProcesados = featuresCrudas.map((feature) {
        return AvisoCortoPlazo.fromGeoJson(feature as Map<String, dynamic>);
      }).toList();

      // 🛡️ Filtro de seguridad: descartamos avisos que por algún error hayan venido sin coordenadas válidas
      final avisosValidos = avisosProcesados.where((aviso) => aviso.coordenadas.isNotEmpty).toList();

      developer.log(
        "📦 Avisos a muy corto plazo procesados con éxito. Cantidad activa: ${avisosValidos.length}",
        name: 'ClimApp',
      );

      return avisosValidos;
    } catch (e, st) {
      // 🚨 Modo Seguro: Si cae el servidor o hay problemas de red, logueamos y devolvemos vector vacío
      developer.log(
        "Servidor SMN (shortterm) caído o sin red. Activando modo seguro local.",
        name: 'ClimApp',
        error: e,
        stackTrace: st,
      );
      return [];
    }
  }

  /// Método público para forzar la recarga manual (por ejemplo, mediante un botón o un Pull-to-Refresh)
  Future<void> refrescarAvisos() async {
    state = const AsyncValue.loading();
    // AsyncValue.guard se encarga automáticamente de capturar excepciones y pasarlas a AsyncError si falla
    state = await AsyncValue.guard(() => _cargarTodaLaData());
  }
}