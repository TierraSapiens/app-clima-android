import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_clima_01/config/app_theme.dart';
import 'package:app_clima_01/models/clima_model.dart';
import 'package:app_clima_01/services/clima_service.dart';
import 'package:app_clima_01/services/ubicacion_service.dart'; // Importamos tu nuevo servicio GPS

// 1. El estado del controlador que consumirá la UI
class PantallaClimaEstado {
  final String localidadActual;
  final String estadoClimaActual;
  final Color colorFondoSuperior;
  final Color colorFondoInferior;
  final ClimaRespuesta? climaActual;
  final List<ClimaDia> pronosticoTresDias;
  final double latitudGuardada;
  final double longitudGuardada;
  final String subtextoAvisos;
  final String subtextoAlertas;
  final Color colorAvisosSMN;
  final Color colorAlertasSMN;
  final IconData iconoAvisos;
  final IconData iconoAlertas;

  PantallaClimaEstado({
    required this.localidadActual,
    required this.estadoClimaActual,
    required this.colorFondoSuperior,
    required this.colorFondoInferior,
    this.climaActual,
    required this.pronosticoTresDias,
    required this.latitudGuardada,
    required this.longitudGuardada,
    required this.subtextoAvisos,
    required this.subtextoAlertas,
    required this.colorAvisosSMN,
    required this.colorAlertasSMN,
    required this.iconoAvisos,
    required this.iconoAlertas,
  });

  PantallaClimaEstado copyWith({
    String? localidadActual,
    String? estadoClimaActual,
    Color? colorFondoSuperior,
    Color? colorFondoInferior,
    ClimaRespuesta? climaActual,
    List<ClimaDia>? pronosticoTresDias,
    double? latitudGuardada,
    double? longitudGuardada,
    String? subtextoAvisos,
    String? subtextoAlertas,
    Color? colorAvisosSMN,
    Color? colorAlertasSMN,
    IconData? iconoAvisos,
    IconData? iconoAlertas,
  }) {
    return PantallaClimaEstado(
      localidadActual: localidadActual ?? this.localidadActual,
      estadoClimaActual: estadoClimaActual ?? this.estadoClimaActual,
      colorFondoSuperior: colorFondoSuperior ?? this.colorFondoSuperior,
      colorFondoInferior: colorFondoInferior ?? this.colorFondoInferior,
      climaActual: climaActual ?? this.climaActual,
      pronosticoTresDias: pronosticoTresDias ?? this.pronosticoTresDias,
      latitudGuardada: latitudGuardada ?? this.latitudGuardada,
      longitudGuardada: longitudGuardada ?? this.longitudGuardada,
      subtextoAvisos: subtextoAvisos ?? this.subtextoAvisos,
      subtextoAlertas: subtextoAlertas ?? this.subtextoAlertas,
      colorAvisosSMN: colorAvisosSMN ?? this.colorAvisosSMN,
      colorAlertasSMN: colorAlertasSMN ?? this.colorAlertasSMN,
      iconoAvisos: iconoAvisos ?? this.iconoAvisos,
      iconoAlertas: iconoAlertas ?? this.iconoAlertas,
    );
  }
}

// 2. El Notifier (Controlador) que orquesta los servicios
class PantallaClimaController extends Notifier<PantallaClimaEstado> {
  final ClimaService _climaService = ClimaService();
  final UbicacionService _ubicacionService = UbicacionService(); // Instanciamos el servicio del GPS

  @override
  PantallaClimaEstado build() {
    return PantallaClimaEstado(
      localidadActual: "Buscando ubicación...",
      estadoClimaActual: "Cargando datos del cielo...",
      colorFondoSuperior: AppTheme.backgroundGradientTop,
      colorFondoInferior: AppTheme.backgroundGradientBottom,
      pronosticoTresDias: [],
      latitudGuardada: 0.0,
      longitudGuardada: 0.0,
      subtextoAvisos: "Nivel Verde: Sin advertencias",
      subtextoAlertas: "Nivel Verde: Condiciones normales",
      colorAvisosSMN: const Color(0xFF22C55E),
      colorAlertasSMN: const Color(0xFF22C55E),
      iconoAvisos: Icons.check_circle_outline_rounded,
      iconoAlertas: Icons.shield_outlined,
    );
  }

  void inicializarClima() {
    _calcularFondoPorEstacion();
    _obtenerDatosCompletos();
  }

  void _calcularFondoPorEstacion() {
    final ahora = DateTime.now();
    final mes = ahora.month;
    final dia = grandmaMatch(ahora.day); // Tu cálculo original

    Color sup, inf;
    if ((mes == 3 && dia >= 21) || mes == 4 || mes == 5 || (mes == 6 && dia < 21)) {
      sup = AppTheme.backgroundSpringTop;
      inf = AppTheme.backgroundSpringBottom;
    } else if ((mes == 6 && dia >= 21) || mes == 7 || mes == 8 || (mes == 9 && dia < 21)) {
      sup = AppTheme.backgroundSummerTop;
      inf = AppTheme.backgroundSummerBottom;
    } else if ((mes == 9 && dia >= 21) || mes == 10 || mes == 11 || (mes == 12 && dia < 21)) {
      sup = AppTheme.backgroundAutumnTop;
      inf = AppTheme.backgroundAutumnBottom;
    } else {
      sup = AppTheme.backgroundWinterTop;
      inf = AppTheme.backgroundWinterBottom;
    }

    state = state.copyWith(colorFondoSuperior: sup, colorFondoInferior: inf);
  }

  int grandmaMatch(int day) => day; // Auxiliar estacional

  Future<void> _obtenerDatosCompletos() async {
    try {
      // Llamamos al servicio dedicado del GPS de forma súper limpia
      final datosUbicacion = await _ubicacionService.obtenerUbicacionActual();
      
      state = state.copyWith(
        latitudGuardada: datosUbicacion.latitud,
        longitudGuardada: datosUbicacion.longitud,
        localidadActual: datosUbicacion.localidad,
      );

      // Procedemos a pedir el clima con las coordenadas obtenidas
      await _obtenerDatosDeAmbasAPIs(datosUbicacion.latitud, datosUbicacion.longitud);

    } catch (e) {
      // Capturamos cualquier error lanzado por UbicacionService (GPS apagado, permisos denegados, etc.)
      String mensajeError = e.toString().replaceAll("Exception: ", "");
      state = state.copyWith(localidadActual: mensajeError);
    }
  }

  Future<void> _obtenerDatosDeAmbasAPIs(double lat, double lon) async {
    try {
      final respuesta = await _climaService.obtenerDatosClima(lat, lon);
      if (respuesta == null) {
        state = state.copyWith(estadoClimaActual: "No se pudieron cargar los datos");
        return;
      }

      String subAvisos = "No hay avisos";
      String subAlertas = "No hay Alertas";
      Color colAvisos = const Color(0xFF22C55E);
      Color colAlertas = const Color(0xFF22C55E);
      IconData icoAvisos = Icons.check_circle_outline_rounded;
      IconData icoAlertas = Icons.shield_outlined;

      if (respuesta.nivelAlerta == 2) {
        colAvisos = const Color(0xFFF97316);
        subAvisos = "Zonas afectadas por lluvias intensas";
        icoAvisos = Icons.warning_amber_rounded;

        colAlertas = const Color(0xFFEF4444);
        subAlertas = "Zonas críticas: Tormentas severas";
        icoAlertas = Icons.gpp_bad_rounded;
      } else if (respuesta.nivelAlerta == 1) {
        colAvisos = const Color(0xFFF97316);
        subAvisos = "Zonas afectadas por chaparrones";
        icoAvisos = Icons.warning_amber_rounded;

        colAlertas = const Color(0xFF22C55E);
        subAlertas = "No hay Alertas";
        icoAlertas = Icons.shield_outlined;
      }

      state = state.copyWith(
        climaActual: respuesta,
        pronosticoTresDias: respuesta.pronostico,
        subtextoAvisos: subAvisos,
        subtextoAlertas: subAlertas,
        colorAvisosSMN: colAvisos,
        colorAlertasSMN: colAlertas,
        iconoAvisos: icoAvisos,
        iconoAlertas: icoAlertas,
      );
    } catch (e) {
      state = state.copyWith(estadoClimaActual: "Error al sincronizar radares");
    }
  }
}

// 3. Exponemos el nuevo proveedor vinculado a este controlador de pantalla
final pantallaClimaProvider = NotifierProvider<PantallaClimaController, PantallaClimaEstado>(() {
  return PantallaClimaController();
});