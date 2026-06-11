import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/advertencia_model.dart';
import '../../services/advertencias_service.dart';

final advertenciasProvider = FutureProvider<List<AdvertenciaModel>>((
  ref,
) async {
  final advertenciasService = AdvertenciasService();
  return await advertenciasService.fetchAdvertenciasActuales();
});
