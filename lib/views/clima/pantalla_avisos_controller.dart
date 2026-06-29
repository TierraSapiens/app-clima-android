import 'package:latlong2/latlong.dart';
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
// 1. La función matemática pura (fuera de la vista y de cualquier clase)
bool verificarPuntoEnPoligono(LatLng point, List<LatLng> polygon) {
  bool inside = false;
  int j = polygon.length - 1;
  for (int i = 0; i < polygon.length; i++) {
    if ((polygon[i].longitude < point.longitude && polygon[j].longitude >= point.longitude ||
            polygon[j].longitude < point.longitude && polygon[i].longitude >= point.longitude) &&
        (polygon[i].latitude +
                (point.longitude - polygon[i].longitude) /
                    (polygon[j].longitude - polygon[i].longitude) *
                    (polygon[j].latitude - polygon[i].latitude) <
            point.latitude)) {
      inside = !inside;
    }
    j = i;
  }
  return inside;
}

// 2. El Provider que procesa la información para dársela masticada a la vista
final estadoAvisosProvider = Provider.family<Map<String, dynamic>, LatLng>((ref, ubicacionActual) {
  // Escuchamos la lista de avisos
  final avisosAsync = ref.watch(avisosControllerProvider);
  final listaAvisos = avisosAsync.value ?? [];

  // Si no hay avisos en el país, cortamos rápido
  if (listaAvisos.isEmpty) {
    return {
      'tieneAvisoLocal': false,
      'tieneAvisosNacionales': false,
      'tituloAviso': '',
    };
  }
  // Buscamos de forma segura si hay un aviso que coincida con nuestro polígono
  final avisosEnZona = listaAvisos.where((aviso) => verificarPuntoEnPoligono(ubicacionActual, aviso.coordenadas));
  
  final tieneAvisoLocal = avisosEnZona.isNotEmpty;
  final tituloAviso = tieneAvisoLocal ? avisosEnZona.first.titulo : '';

  // Devolvemos los 3 datos que la vista necesita
  return {
    'tieneAvisoLocal': tieneAvisoLocal,
    'tieneAvisosNacionales': true, // Ya sabemos que no está vacía por la validación de arriba
    'tituloAviso': tituloAviso,
  };
});