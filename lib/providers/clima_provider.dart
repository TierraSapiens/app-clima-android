import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:app_clima_01/config/app_theme.dart';
import 'package:app_clima_01/models/clima_model.dart';
import 'package:app_clima_01/services/clima_service.dart';

// 1. Definimos la clase que guardará todos los datos del estado actual
class ClimaEstado {
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

  ClimaEstado({
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

  // Copia el estado anterior y actualiza solo lo que cambia (Es el estándar de Riverpod)
  ClimaEstado copyWith({
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
    return ClimaEstado(
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

// 2. Creamos el Gestor de Estado (Notifier) que ejecuta las funciones de la app
class ClimaNotifier extends Notifier<ClimaEstado> {
  final ClimaService _climaService = ClimaService();

  @override
  ClimaEstado build() {
    // Definimos los valores iniciales por defecto apenas arranca el cerebro
    return ClimaEstado(
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

  // Toda tu antigua lógica de inicialización empaquetada aquí
  void inicializarClima() {
    _calcularFondoPorEstacion();
    _obtenerUbicacionActual();
  }

  void _calcularFondoPorEstacion() {
    final ahora = DateTime.now();
    final mes = ahora.month;
    final dia = ahora.day;

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

  Future<void> _obtenerUbicacionActual() async {
    bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) {
      state = state.copyWith(localidadActual: "GPS apagado");
      return;
    }

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        state = state.copyWith(localidadActual: "Permiso denegado");
        return;
      }
    }

    try {
      Position posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );

      state = state.copyWith(
        latitudGuardada: posicion.latitude,
        longitudGuardada: posicion.longitude,
      );

      List<Placemark> marcas = await placemarkFromCoordinates(posicion.latitude, posicion.longitude);
      if (marcas.isNotEmpty) {
        Placemark lugar = marcas.first;
        state = state.copyWith(
          localidadActual: lugar.locality ?? lugar.administrativeArea ?? "Desconocido",
        );
      }

      await _obtenerDatosDeAmbasAPIs(posicion.latitude, posicion.longitude);
    } catch (e) {
      state = state.copyWith(localidadActual: "Error al buscar");
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

// 3. EXPONEMOS EL PROVEEDOR GLOBAL (La perilla que usará la pantalla para conectarse)
final climaProvider = NotifierProvider<ClimaNotifier, ClimaEstado>(() {
  return ClimaNotifier();
});