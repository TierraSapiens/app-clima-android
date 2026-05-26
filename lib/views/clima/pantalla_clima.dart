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

          return WeatherBackground(
            codigoIconoApi: codigoIcono,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _colorFondoSuperior.withValues(alpha: 0.2), 
                    _colorFondoInferior.withValues(alpha: 0.8),
                  ],
                  stops: const [0.0, 0.65],
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
                                // 1. Bajamos todo el bloque del clima principal
                                Positioned(
                                  top: MediaQuery.of(context).padding.top + 60, // 👈 Más aire arriba
                                  left: 0,
                                  right: 0,
                                  child: Column( // Usamos columna para separar elementos
                                    children: [
                                      // 2. Ciudad y Menú en la misma línea (como en el render)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              data.localidad,
                                              style: TextStyle( // Texto de ciudad más prominente
                                                color: Colors.white,
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                                              onPressed: () => Scaffold.of(context).openDrawer(),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 60), // 👈 GRAN ESPACIO entre ciudad y clima

                                      // 3. El bloque de clima propiamente dicho
                                      TarjetaClimaPrincipal(
                                        localidad: '', // Dejamos la localidad vacía aquí
                                        respuesta: data.clima,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                    const SizedBox(height: 8),
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
} // Fin de la clase