import 'package:app_clima_01/views/clima/pantalla_advertencias.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_clima_01/views/clima/pantalla_alertas.dart';
import 'package:app_clima_01/views/clima/pantalla_avisos.dart';
import 'package:app_clima_01/views/clima/pantalla_clima_controller.dart';
import 'package:app_clima_01/views/clima/pantalla_alertas_controller.dart';
import 'package:app_clima_01/views/clima/widgets/boton_emergencia.dart';
import 'package:app_clima_01/global_widgets/menu_lateral.dart';
import 'package:app_clima_01/views/clima/widgets/tarjeta_clima_principal.dart';
import 'package:app_clima_01/views/clima/widgets/tarjeta_dia.dart';
import 'package:app_clima_01/views/clima/widgets/weather_background.dart';
import 'package:app_clima_01/views/clima/pantalla_avisos_controller.dart';
import 'package:app_clima_01/views/clima/advertencias_controller.dart';

class PantallaClima extends ConsumerStatefulWidget {
  const PantallaClima({super.key});

  @override
  ConsumerState<PantallaClima> createState() => _PantallaClimaState();
}

class _PantallaClimaState extends ConsumerState<PantallaClima> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(climaProvider.notifier).load();
    });
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

  @override
  Widget build(BuildContext context) {
    final climaEstado = ref.watch(climaProvider);
    final tieneAlertasFuturas =
        ref.watch(tieneAlertasActivasCualquierDiaProvider).value ?? false;

    return Scaffold(
      drawer: const MenuLateral(),
      body: Builder(
        builder: (context) {
          final climaData = climaEstado.value;
          final codigoIcono = climaData?.clima.codigoIcono ?? '01d';

          return WeatherBackground(
            codigoIconoApi: codigoIcono,
            child: RefreshIndicator(
              color: Colors.white,
              backgroundColor: const Color(0xFF1E1E1E),
              onRefresh: () async {
                await ref.read(climaProvider.notifier).load();
                ref.invalidate(tieneAlertasActivasCualquierDiaProvider);
                ref.invalidate(
                  advertenciasProvider,
                ); // Actualiza también las advertencias al deslizar
              },
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: climaEstado.isLoading
                      ? Padding(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.35,
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
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
                      : climaEstado.hasError || climaData == null
                      ? Padding(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.35,
                          ),
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
                                    : 'No hay datos disponibles',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Stack(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: //clima principal altura
                                        MediaQuery.of(context).padding.top + 12,
                                  ),
                                  child: TarjetaClimaPrincipal(
                                    localidad: climaData.localidad,
                                    respuesta: climaData.clima,
                                    lat: climaData.lat,
                                    lon: climaData.lon,
                                  ),
                                ),
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
                            ),
                            // El Pronostico
                            const SizedBox(height: 9),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                                horizontal: 24.0,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (climaData.clima.pronostico.isNotEmpty)
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: climaData.clima.pronostico
                                            .map((dia) {
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
                                            })
                                            .toList(),
                                      ),
                                    ),
                                  // AVISOS
                                  const SizedBox(height: 32),
                                  Consumer(
                                    builder: (context, ref, child) {
                                      final avisosAsync = ref.watch(
                                        avisosControllerProvider,
                                      );
                                      final listaAvisos =
                                          avisosAsync.value ?? [];
                                      final LatLng puntoConsulta = LatLng(
                                        climaData.lat,
                                        climaData.lon,
                                      );

                                      bool verificarPuntoEnPoligono(
                                        LatLng point,
                                        List<LatLng> polygon,
                                      ) {
                                        bool inside = false;
                                        int j = polygon.length - 1;
                                        for (
                                          int i = 0;
                                          i < polygon.length;
                                          i++
                                        ) {
                                          if ((polygon[i].longitude <
                                                          point.longitude &&
                                                      polygon[j].longitude >=
                                                          point.longitude ||
                                                  polygon[j].longitude <
                                                          point.longitude &&
                                                      polygon[i].longitude >=
                                                          point.longitude) &&
                                              (polygon[i].latitude +
                                                      (point.longitude -
                                                              polygon[i]
                                                                  .longitude) /
                                                          (polygon[j]
                                                                  .longitude -
                                                              polygon[i]
                                                                  .longitude) *
                                                          (polygon[j].latitude -
                                                              polygon[i]
                                                                  .latitude) <
                                                  point.latitude)) {
                                            inside = !inside;
                                          }
                                          j = i;
                                        }
                                        return inside;
                                      }

                                      final bool tieneAvisoLocal = listaAvisos
                                          .any(
                                            (aviso) => verificarPuntoEnPoligono(
                                              puntoConsulta,
                                              aviso.coordenadas,
                                            ),
                                          );
                                      final bool tieneAvisosNacionales =
                                          listaAvisos.isNotEmpty;
                                      final String textoMarquesina =
                                          tieneAvisoLocal
                                          ? '¡CORTO PLAZO EN TU ZONA: ${listaAvisos.firstWhere((a) => verificarPuntoEnPoligono(puntoConsulta, a.coordenadas)).titulo}! '
                                          : tieneAvisosNacionales
                                          ? 'No hay avisos en tu zona (Hay alertas en el país)'
                                          : 'Sin Avisos';

                                      return BotonEmergencia(
                                        texto: "AVISOS",
                                        subtexto: textoMarquesina,
                                        colorAccento: tieneAvisoLocal
                                            ? const Color(0xFFE65100)
                                            : Colors.white54,
                                        colorSubtexto: tieneAvisoLocal
                                            ? Colors.amberAccent
                                            : Colors.white38,
                                        icono: tieneAvisoLocal
                                            ? Icons.thunderstorm_rounded
                                            : Icons
                                                  .check_circle_outline_rounded,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const PantallaAvisos(),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 14),

                                  // ADVERTENCIAS
                                  Consumer(
                                    builder: (context, ref, child) {
                                      final advertenciasAsync = ref.watch(
                                        advertenciasProvider,
                                      );
                                      final listaAdvertencias =
                                          advertenciasAsync.value ?? [];
                                      final bool hayAdvertencias =
                                          listaAdvertencias.isNotEmpty;

                                      final String descripcion = hayAdvertencias
                                          ? '¡Hay ${listaAdvertencias.length} advertencias activas en el país!'
                                          : 'Sin Advertencias';

                                      return BotonEmergencia(
                                        texto: "ADVERTENCIAS",
                                        subtexto: descripcion,
                                        colorAccento: hayAdvertencias
                                            ? const Color(0xFFE65100)
                                            : Colors.white54,
                                        colorSubtexto: hayAdvertencias
                                            ? Colors.amberAccent
                                            : Colors.white38,
                                        icono: hayAdvertencias
                                            ? Icons.info_outline_rounded
                                            : Icons
                                                  .check_circle_outline_rounded,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const PantallaAdvertencias(),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 14),

                                  // ALERTAS
                                  Consumer(
                                    builder: (context, ref, child) {
                                      final nivelLocalAsync = ref.watch(
                                        nivelAlertaLocalProvider(
                                          LatLng(climaData.lat, climaData.lon),
                                        ),
                                      );
                                      final int nivelAlertaLocal =
                                          nivelLocalAsync.value ?? 1;
                                      final bool tieneAlertaLocal =
                                          nivelAlertaLocal > 1;

                                      return BotonEmergencia(
                                        texto: "ALERTAS",
                                        subtexto: tieneAlertasFuturas
                                            ? '¡Hay Alerta!'
                                            : climaData.subtextoAlertas,
                                        colorAccento: tieneAlertaLocal
                                            ? const Color(0xFFE65100)
                                            : Colors.white54,
                                        colorSubtexto: tieneAlertasFuturas
                                            ? Colors.amberAccent
                                            : climaData.subtextoAlertas
                                                  .toLowerCase()
                                                  .contains('no hay')
                                            ? Colors.white38
                                            : Colors.amber,
                                        icono: tieneAlertaLocal
                                            ? Icons.warning_amber_rounded
                                            : climaData.iconoAlertas,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const PantallaAlertas(),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
