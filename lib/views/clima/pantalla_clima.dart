import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
// IMPORTANTE: Ahora importamos el controlador de su propia carpeta de vista
import 'package:app_clima_01/views/clima/pantalla_clima_controller.dart'; 
import 'package:app_clima_01/views/clima/widgets/boton_emergencia.dart';
import 'package:app_clima_01/views/global_widgets/menu_lateral.dart';
import 'package:app_clima_01/views/clima/widgets/tarjeta_clima_principal.dart';
import 'package:app_clima_01/views/clima/widgets/tarjeta_dia.dart';

class PantallaClima extends ConsumerStatefulWidget {
  const PantallaClima({super.key});

  @override
  ConsumerState<PantallaClima> createState() => _PantallaClimaState();
}

class _PantallaClimaState extends ConsumerState<PantallaClima> {
  
  @override
  void initState() {
    super.initState();
    // Llamamos al nuevo controlador de la pantalla para iniciar el flujo
    Future.microtask(() {
      ref.read(pantallaClimaProvider.notifier).inicializarClima();
    });
  }

  Future<void> _abrirGraficoDetallado() async {
    // Leemos las coordenadas guardadas en el nuevo estado de la pantalla
    final estado = ref.read(pantallaClimaProvider); 
    final String urlFormada = 'https://meteoblue.com{estado.latitudGuardada}&lon=${estado.longitudGuardada}';
    final Uri uri = Uri.parse(urlFormada);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Error al abrir navegador: $e");
    }
  }

  Future<void> _abrirAlertasSMN() async {
    final Uri uri = Uri.parse('https://smn.gob.ar');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Error al abrir alertas SMN: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos el nuevo proveedor específico de esta pantalla
    final climaEstado = ref.watch(pantallaClimaProvider);

    return Scaffold(
      drawer: const MenuLateral(),
      body: Builder(
        builder: (context) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [climaEstado.colorFondoSuperior, climaEstado.colorFondoInferior],
                stops: const [0.0, 0.65],
              ),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  
                  // 1. CLIMA ACTUAL (STACK DE BORDE A BORDE)
                  climaEstado.climaActual == null
                      ? const Padding(
                          padding: EdgeInsets.only(top: 150.0),
                          child: Center(child: CircularProgressIndicator(color: Colors.white)),
                        )
                      : Stack(
                          children: [
                            TarjetaClimaPrincipal(
                              localidad: climaEstado.localidadActual,
                              respuesta: climaEstado.climaActual!,
                            ),
                            Positioned(
                              top: MediaQuery.of(context).padding.top + 10,
                              left: 16,
                              child: IconButton(
                                icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                                onPressed: () => Scaffold.of(context).openDrawer(),
                              ),
                            ),
                          ],
                        ),

                  // 2. CONTENIDO INFERIOR CON DATOS ENLAZADOS AL CONTROLADOR
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        
                        // Fila de pronósticos con Scroll Horizontal
                        climaEstado.pronosticoTresDias.isEmpty
                            ? const SizedBox()
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: climaEstado.pronosticoTresDias.map((dia) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 12.0),
                                      child: TarjetaDia(
                                        dia: dia.fechaLabel,
                                        icono: dia.icono,
                                        colorIcono: dia.colorIcono,
                                        temp: dia.tempMaxMin,
                                        estado: dia.estado,
                                        onTap: _abrirGraficoDetallado,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),

                        const SizedBox(height: 40),

                        // Botones de Emergencia enlazados al nuevo estado
                        BotonEmergencia(
                          texto: "AVISOS METEOROLÓGICOS",
                          subtexto: climaEstado.subtextoAvisos,
                          colorAccento: climaEstado.colorAvisosSMN,
                          icono: climaEstado.iconoAvisos,
                          onTap: _abrirAlertasSMN,
                        ),

                        const SizedBox(height: 16),

                        BotonEmergencia(
                          texto: "ALERTAS CRÍTICAS",
                          subtexto: climaEstado.subtextoAlertas,
                          colorAccento: climaEstado.colorAlertasSMN,
                          icono: climaEstado.iconoAlertas,
                          onTap: _abrirAlertasSMN,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}