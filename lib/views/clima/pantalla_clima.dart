import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_clima_01/views/clima/pantalla_alertas.dart';
import 'package:app_clima_01/views/clima/pantalla_avisos.dart';
import 'package:app_clima_01/views/clima/pantalla_clima_controller.dart';
import 'package:app_clima_01/views/clima/pantalla_alertas_controller.dart'; // 👈 1. IMPORTAMOS TU CONTROLADOR DE ALERTAS
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
    
    // 📡 2. ESCUCHAMOS EL ESCÁNER DE LOS 3 DÍAS EN TIEMPO REAL
    // Si da true (como por la alerta del miércoles), el botón cambiará de aspecto al instante.
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
                // Aprovechamos y refrescamos también el escáner global
                ref.invalidate(tieneAlertasActivasCualquierDiaProvider);
              },
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      climaEstado.isLoading
                          ? const Padding(
                              padding: EdgeInsets.only(top: 150.0),
                              child: Column(
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
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: MediaQuery.of(context).padding.top + 15,
                                      ),
                                      child: TarjetaClimaPrincipal(
                                        localidad: data.localidad,
                                        respuesta: data.clima,
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
                                );
                              },
                            ),
                      const SizedBox(height: 14), 
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
                            const SizedBox(height: 32), 

                            // 🟢 BOTÓN DE AVISOS (Se conserva igual)
                            BotonEmergencia(
                              texto: "AVISOS",
                              subtexto: climaEstado.value?.subtextoAvisos ?? 'No hay avisos',
                              colorAccento: const Color(0xFF35c795), 
                              colorSubtexto: (climaEstado.value?.subtextoAvisos.toLowerCase().contains('no hay') ?? true)
                                  ? Colors.white38 
                                  : Colors.amber,
                              icono: climaEstado.value?.iconoAvisos ?? Icons.check_circle_outline_rounded,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const PantallaAvisos()),
                                );
                              },
                            ),

                            const SizedBox(height: 14), 

                            // ⚡ 3. BOTÓN DE ALERTAS DINÁMICO ("ASUSTADIZO")
                            BotonEmergencia(
                              texto: "ALERTAS",
                              // Si detecta alertas en el futuro, pisa el texto local por uno de advertencia
                              subtexto: tieneAlertasFuturas 
                                  ? '¡Hay Alerta!' 
                                  : (climaEstado.value?.subtextoAlertas ?? 'No hay alertas'),
                              // Si hay alertas pasa al naranja llamativo de tu AppBar, sino queda en verde amigable
                              colorAccento: tieneAlertasFuturas 
                                  ? const Color(0xFFE65100) 
                                  : const Color(0xFF35c795), 
                              colorSubtexto: tieneAlertasFuturas 
                                  ? Colors.amberAccent 
                                  : (climaEstado.value?.subtextoAlertas.toLowerCase().contains('no hay') ?? true)
                                      ? Colors.white38 
                                      : Colors.amber,
                              // Si hay alerta cambia el escudo por un triángulo de advertencia
                              icono: tieneAlertasFuturas 
                                  ? Icons.warning_amber_rounded 
                                  : (climaEstado.value?.iconoAlertas ?? Icons.shield_outlined),
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