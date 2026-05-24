import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_clima_01/services/clima_service.dart';
import 'package:app_clima_01/services/ubicacion_service.dart';
import 'package:app_clima_01/models/clima_model.dart';

class ClimaViewData {
  final ClimaRespuesta clima;
  final String localidad;
  final double lat;
  final double lon;
  final Color colorAvisos;
  final Color colorAlertas;
  final String subtextoAvisos;
  final String subtextoAlertas;
  final IconData iconoAvisos;
  final IconData iconoAlertas;

  ClimaViewData({
    required this.clima,
    required this.localidad,
    required this.lat,
    required this.lon,
    required this.colorAvisos,
    required this.colorAlertas,
    required this.subtextoAvisos,
    required this.subtextoAlertas,
    required this.iconoAvisos,
    required this.iconoAlertas,
  });
}

final climaProvider = AsyncNotifierProvider<ClimaController, ClimaViewData?>(ClimaController.new);

class ClimaController extends AsyncNotifier<ClimaViewData?> {
  final ClimaService _climaService = ClimaService();
  final UbicacionService _ubicacionService = UbicacionService();

  @override
  Future<ClimaViewData?> build() async {
    return null;
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final ubicacion = await _ubicacionService.obtenerUbicacionActual();
      final double lat = ubicacion.latitud;
      final double lon = ubicacion.longitud;
      final String localidad = ubicacion.localidad;

      final climaResp = await _climaService.obtenerDatosClima(lat, lon);
      if (climaResp == null) {
        state = AsyncValue.error(Exception('No se pudieron cargar los datos'), StackTrace.current);
        return;
      }

      Color colorAvisosSMN = const Color(0xFF22C55E);
      Color colorAlertasSMN = const Color(0xFF22C55E);
      String subtextoAvisos = 'No hay avisos';
      String subtextoAlertas = 'No hay Alertas';
      IconData iconoAvisos = Icons.check_circle_outline_rounded;
      IconData iconoAlertas = Icons.shield_outlined;

      if (climaResp.nivelAlerta == 2) {
        colorAvisosSMN = const Color(0xFFF97316);
        subtextoAvisos = 'Zonas afectadas por lluvias intensas';
        iconoAvisos = Icons.warning_amber_rounded;

        colorAlertasSMN = const Color(0xFFEF4444);
        subtextoAlertas = 'Zonas críticas: Tormentas severas';
        iconoAlertas = Icons.gpp_bad_rounded;
      } else if (climaResp.nivelAlerta == 1) {
        colorAvisosSMN = const Color(0xFFF97316);
        subtextoAvisos = 'Zonas afectadas por chaparrones';
        iconoAvisos = Icons.warning_amber_rounded;

        colorAlertasSMN = const Color(0xFF22C55E);
        subtextoAlertas = 'No hay Alertas';
        iconoAlertas = Icons.shield_outlined;
      }

      final view = ClimaViewData(
        clima: climaResp,
        localidad: localidad,
        lat: lat,
        lon: lon,
        colorAvisos: colorAvisosSMN,
        colorAlertas: colorAlertasSMN,
        subtextoAvisos: subtextoAvisos,
        subtextoAlertas: subtextoAlertas,
        iconoAvisos: iconoAvisos,
        iconoAlertas: iconoAlertas,
      );

      state = AsyncValue.data(view);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
