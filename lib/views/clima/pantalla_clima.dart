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
    final tieneAlertasFuturas = ref.watch(tieneAlertasActivasCualquierDiaProvider).value ?? false;

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
              },
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  // 🧠 CONTROL TOTAL DE ESTADOS: Evaluamos toda la pantalla junta
                  child: climaEstado.isLoading
                      ? Padding(
                          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.35),
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
                              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.35),
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
                                // 🌟 SECCIÓN 1: Tarjeta Principal y Botón de Menú
                                Stack(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: MediaQuery.of(context).padding.top + 15,
                                      ),
                                      child: TarjetaClimaPrincipal(
                                        localidad: climaData.localidad,
                                        respuesta: climaData.clima,
                                        lat: climaData.lat, // 👈 Pasado perfecto y seguro
                                        lon: climaData.lon, // 👈 Pasado perfecto y seguro
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
                                        onPressed: () => Scaffold.of(context).openDrawer(),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 14), 
                                
                                // 🌟 SECCIÓN 2: Pronóstico y Botones de Emergencia
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12.0,
                                    horizontal: 24.0,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Renderizado seguro del pronóstico usando la variable 'climaData'
                                      if (climaData.clima.pronostico.isNotEmpty)
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          physics: const BouncingScrollPhysics(),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: climaData.clima.pronostico.map(
                                              (dia) {
                                                return Padding(
                                                  padding: const EdgeInsets.only(right: 12.0),
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
                                        
                                      const SizedBox(height: 32), 

                                      // 🟢 BOTÓN DE AVISOS DINÁMICO (LOCALIZADO POR RAY-CASTING)
                                      Consumer(
                                        builder: (context, ref, child) {
                                          // 1. Escuchamos todos los avisos del país
                                          final avisosAsync = ref.watch(avisosControllerProvider);
                                          final listaAvisos = avisosAsync.value ?? [];
                                          
                                          // 2. Capturamos el punto actual (Ubicación real o Favorito seleccionado)
                                          final LatLng puntoConsulta = LatLng(climaData.lat, climaData.lon);

                                          // 🧮 Algoritmo Ray-Casting para verificar si el punto está dentro del polígono del aviso
                                          bool verificarPuntoEnPoligono(LatLng point, List<LatLng> polygon) {
                                            bool inside = false;
                                            int j = polygon.length - 1;
                                            for (int i = 0; i < polygon.length; i++) {
                                              if ((polygon[i].longitude < point.longitude && polygon[j].longitude >= point.longitude ||
                                                   polygon[j].longitude < point.longitude && polygon[i].longitude >= point.longitude) &&
                                                  (polygon[i].latitude + (point.longitude - polygon[i].longitude) /
                                                   (polygon[j].longitude - polygon[i].longitude) * (polygon[j].latitude - polygon[i].latitude) < point.latitude)) {
                                                inside = !inside;
                                              }
                                              j = i;
                                            }
                                            return inside;
                                          }

                                          // 3. Filtramos si ALGUN aviso del país toca la ciudad que estamos mirando
                                          final bool tieneAvisoLocal = listaAvisos.any((aviso) => verificarPuntoEnPoligono(puntoConsulta, aviso.coordenadas));
                                          final bool tieneAvisosNacionales = listaAvisos.isNotEmpty;

                                          // 📝 Estrategia de texto: Avisa el estado local, o si hay algo en el resto del país
                                          final String textoMarquesina = tieneAvisoLocal
                                              ? '¡CORTO PLAZO EN TU ZONA: ${listaAvisos.firstWhere((a) => verificarPuntoEnPoligono(puntoConsulta, a.coordenadas)).titulo}! '
                                              : tieneAvisosNacionales
                                                  ? 'No hay avisos en tu zona (Hay alertas en el país)'
                                                  : 'No hay avisos';

                                          return BotonEmergencia(
                                            texto: "AVISOS",
                                            subtexto: textoMarquesina,
                                            // 🚨 LA ALARMA SOLO SALTA (NARANJA) SI TE AFECTA A VOS O A TU FAVORITO EN PANTALLA
                                            colorAccento: tieneAvisoLocal
                                                ? const Color(0xFFE65100) // Naranja Alerta Máxima
                                                : const Color(0xFF35c795), // color palabra AVISOS
                                            colorSubtexto: tieneAvisoLocal
                                                ? Colors.amberAccent
                                                : Colors.white38,
                                            // 🔄 El ícono también es inteligente: Rayo si te toca, Check si estás a salvo
                                            icono: tieneAvisoLocal 
                                                ? Icons.thunderstorm_rounded 
                                                : Icons.check_circle_outline_rounded,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => const PantallaAvisos()),
                                              );
                                            },
                                          );
                                        },
                                      ),

                                      const SizedBox(height: 14), 

                                      // ⚡ BOTÓN DE ALERTAS DINÁMICO (HÍBRIDO INTELIGENTE)
                                      Consumer(
                                        builder: (context, ref, child) {
                                          // Leemos el nivel de alerta local usando la latitud y longitud de la ciudad actual
                                          final nivelLocalAsync = ref.watch(nivelAlertaLocalProvider(LatLng(climaData.lat, climaData.lon)));
                                          final int nivelAlertaLocal = nivelLocalAsync.value ?? 1;
                                          final bool tieneAlertaLocal = nivelAlertaLocal > 1;

                                          return BotonEmergencia(
                                            texto: "ALERTAS",
                                            // 🇦🇷 El texto sigue avisando a nivel nacional (lo dejamos exactamente igual)
                                            subtexto: tieneAlertasFuturas 
                                                ? '¡Hay Alerta!' 
                                                : climaData.subtextoAlertas,
                                            // 📍 El color ahora es selectivo: naranja solo si la alerta toca tu ciudad
                                            colorAccento: tieneAlertaLocal 
                                                ? const Color(0xFFE65100) 
                                                : const Color(0xFF35c795), // Color palabra ALERTA
                                            colorSubtexto: tieneAlertasFuturas 
                                                ? Colors.amberAccent 
                                                : climaData.subtextoAlertas.toLowerCase().contains('no hay')
                                                    ? Colors.white38 
                                                    : Colors.amber,
                                            // 📍 El ícono de peligro también reacciona solo si es local
                                            icono: tieneAlertaLocal 
                                                ? Icons.warning_amber_rounded 
                                                : climaData.iconoAlertas,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => const PantallaAlertas()),
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