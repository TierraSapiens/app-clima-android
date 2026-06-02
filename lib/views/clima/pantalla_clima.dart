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

                                      // 🟢 BOTÓN DE AVISOS
                                      BotonEmergencia(
                                        texto: "AVISOS",
                                        subtexto: climaData.subtextoAvisos.isEmpty 
                                            ? 'No hay avisos' 
                                            : climaData.subtextoAvisos,
                                        colorAccento: const Color(0xFF35c795), 
                                        colorSubtexto: climaData.subtextoAvisos.toLowerCase().contains('no hay')
                                            ? Colors.white38 
                                            : Colors.amber,
                                        icono: climaData.iconoAvisos,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const PantallaAvisos()),
                                          );
                                        },
                                      ),

                                      const SizedBox(height: 14), 

                                      // ⚡ BOTÓN DE ALERTAS DINÁMICO ("ASUSTADIZO")
                                      BotonEmergencia(
                                        texto: "ALERTAS",
                                        subtexto: tieneAlertasFuturas 
                                            ? '¡Hay Alerta!' 
                                            : climaData.subtextoAlertas,
                                        colorAccento: tieneAlertasFuturas 
                                            ? const Color(0xFFE65100) 
                                            : const Color(0xFF35c795), 
                                        colorSubtexto: tieneAlertasFuturas 
                                            ? Colors.amberAccent 
                                            : climaData.subtextoAlertas.toLowerCase().contains('no hay')
                                                ? Colors.white38 
                                                : Colors.amber,
                                        icono: tieneAlertasFuturas 
                                            ? Icons.warning_amber_rounded 
                                            : climaData.iconoAlertas,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const PantallaAlertas()),
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