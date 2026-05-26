import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_clima_01/config/app_theme.dart';
import 'package:app_clima_01/views/clima/pantalla_clima_controller.dart';
import 'package:app_clima_01/views/clima/widgets/boton_emergencia.dart';
import 'package:app_clima_01/global_widgets/menu_lateral.dart';
import 'package:app_clima_01/views/clima/widgets/tarjeta_clima_principal.dart';
import 'package:app_clima_01/views/clima/widgets/tarjeta_dia.dart';
import 'package:app_clima_01/views/clima/widgets/weather_background.dart';

class PantallaClima extends ConsumerStatefulWidget {
  const PantallaClima({super.key});

  @override
  ConsumerState<PantallaClima> createState() => _PantallaClimaState();
}

class _PantallaClimaState extends ConsumerState<PantallaClima> {
  Color _colorFondoSuperior = AppTheme.backgroundGradientTop;
  Color _colorFondoInferior = AppTheme.backgroundGradientBottom;

  @override
  void initState() {
    super.initState();
    _calcularFondoPorEstacion();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(climaProvider.notifier).load();
    });
  }

  void _calcularFondoPorEstacion() {
    final ahora = DateTime.now();
    final mes = ahora.month;
    final dia = ahora.day;

    if ((mes == 3 && dia >= 21) ||
        mes == 4 ||
        mes == 5 ||
        (mes == 6 && dia < 21)) {
      _colorFondoSuperior = AppTheme.backgroundSpringTop;
      _colorFondoInferior = AppTheme.backgroundSpringBottom;
    } else if ((mes == 6 && dia >= 21) ||
        mes == 7 ||
        mes == 8 ||
        (mes == 9 && dia < 21)) {
      _colorFondoSuperior = AppTheme.backgroundSummerTop;
      _colorFondoInferior = AppTheme.backgroundSummerBottom;
    } else if ((mes == 9 && dia >= 21) ||
        mes == 10 ||
        mes == 11 ||
        (mes == 12 && dia < 21)) {
      _colorFondoSuperior = AppTheme.backgroundAutumnTop;
      _colorFondoInferior = AppTheme.backgroundAutumnBottom;
    } else {
      _colorFondoSuperior = AppTheme.backgroundWinterTop;
      _colorFondoInferior = AppTheme.backgroundWinterBottom;
    }
  }

  Future<void> _abrirGraficoDetallado() async {
    final estado = ref.read(climaProvider);
    final data = estado.value;
    if (data == null) return;
    final String urlFormada =
        'https://www.meteoblue.com/es/tiempo/semana/index/index?lat=${data.lat}&lon=${data.lon}';
    final Uri uri = Uri.parse(urlFormada);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Error al abrir navegador: $e");
    }
  }

  Future<void> _abrirAlertasSMN() async {
    final Uri uri = Uri.parse('https://www.smn.gob.ar/alertas');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Error al abrir alertas SMN: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final climaEstado = ref.watch(climaProvider);

    return Scaffold(
      drawer: const MenuLateral(),
      body: Builder(
        builder: (context) {
          final climaData = climaEstado.value;
          final codigoIcono = climaData?.clima.codigoIcono ?? '01d'; 

          // 1. El WeatherBackground va abajo de todo para pintar las nubes reales
          return WeatherBackground(
            codigoIconoApi: codigoIcono,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              // 2. Controlamos el degradé con transparencia absoluta (.withValues)
              // para que funcione como un filtro de color y NO tape la foto de fondo
              decoration: BoxDecoration(
                // ✏️ REEMPLÁZALO POR ESTE:
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _colorFondoSuperior.withValues(alpha: 0.15),  // 👈 Filtro sutil con el color de la estación arriba
                    _colorFondoInferior.withValues(alpha: 0.75),  // 👈 Oscuro abajo para que resalten los botones
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    climaEstado.isLoading
                        ? Padding(
                            padding: const EdgeInsets.only(top: 150.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Buscando ubicación...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 20),
                                CircularProgressIndicator(color: Colors.white),
                              ],
                            ),
                          )
                        : climaEstado.hasError || climaEstado.value == null
                        ? Padding(
                            padding: const EdgeInsets.only(top: 120.0),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.white,
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  climaEstado.hasError
                                      ? climaEstado.error.toString()
                                      : 'No hay datos',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          )
                        : Builder(
                            builder: (_) {
                              final data = climaEstado.value!;
                              return Stack(
                                children: [
                                  // La tarjeta dibuja la ciudad centrada y el clima arriba como en Movil 3
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).padding.top + 15,
                                    ),
                                    child: TarjetaClimaPrincipal(
                                      localidad: data.localidad,
                                      respuesta: data.clima,
                                    ),
                                  ),
                                  // El menú hamburguesa clavado arriba a la izquierda
                                  Positioned(
                                    top: MediaQuery.of(context).padding.top + 10,
                                    left: 16,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.menu,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                      onPressed: () =>
                                          Scaffold.of(context).openDrawer(),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                    const SizedBox(height: 14), // Espaciado perfecto con el pronóstico semanal
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 24.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          (climaEstado.value?.clima.pronostico ?? []).isEmpty
                              ? const SizedBox()
                              : SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children:
                                        (climaEstado.value!.clima.pronostico).map(
                                      (dia) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            right: 12.0,
                                          ),
                                          child: TarjetaDia(
                                            dia: dia.fechaLabel,
                                            imagenAsset: dia.imagenAsset,
                                            colorIcono: dia.colorIcono,
                                            temp: dia.tempMaxMin,
                                            estado: dia.estado,
                                            onTap: _abrirGraficoDetallado,
                                          ),
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ),
                          const SizedBox(height: 12),
                          BotonEmergencia(
                            texto: "AVISOS METEOROLÓGICOS",
                            subtexto:
                                climaEstado.value?.subtextoAvisos ??
                                'No hay avisos',
                            colorAccento:
                                climaEstado.value?.colorAvisos ??
                                const Color(0xFF22C55E),
                            icono:
                                climaEstado.value?.iconoAvisos ??
                                Icons.check_circle_outline_rounded,
                            onTap: _abrirAlertasSMN,
                          ),
                          const SizedBox(height: 16),
                          BotonEmergencia(
                            texto: "ALERTAS CRÍTICAS",
                            subtexto:
                                climaEstado.value?.subtextoAlertas ??
                                'No hay alertas',
                            colorAccento:
                                climaEstado.value?.colorAlertas ??
                                const Color(0xFF22C55E),
                            icono:
                                climaEstado.value?.iconoAlertas ??
                                Icons.shield_outlined,
                            onTap: _abrirAlertasSMN,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}