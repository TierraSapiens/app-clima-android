import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Importamos Riverpod
import 'package:url_launcher/url_launcher.dart';
import 'package:app_clima_01/providers/clima_provider.dart'; // Importamos tu nuevo cerebro
import 'package:app_clima_01/views/clima/widgets/boton_emergencia.dart';
import 'package:app_clima_01/views/global_widgets/menu_lateral.dart';
import 'package:app_clima_01/views/clima/widgets/tarjeta_clima_principal.dart';
import 'package:app_clima_01/views/clima/widgets/tarjeta_dia.dart';

// CAMBIO CLAVE: Ahora es un ConsumerStatefulWidget para escuchar a Riverpod
class PantallaClima extends ConsumerStatefulWidget {
  const PantallaClima({super.key});

  @override
  ConsumerState<PantallaClima> createState() => _PantallaClimaState();
}

class _PantallaClimaState extends ConsumerState<PantallaClima> {
  
  @override
  void initState() {
    super.initState();
    // Al arrancar, le decimos al proveedor que encienda el GPS y cargue las APIs
    Future.microtask(() {
      ref.read(climaProvider.notifier).inicializarClima();
    });
  }

  // Las funciones de navegación permanecen en la vista por diseño
  Future<void> _abrirGraficoDetallado() async {
    final estado = ref.read(climaProvider); // Leemos las coordenadas del proveedor
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
    // Escuchamos el estado del proveedor. Si algo cambia en el cerebro, la pantalla se redibuja sola.
    final climaEstado = ref.watch(climaProvider);

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
                  
                  // 1. CLIMA ACTUAL (LEÍDO DESDE EL PROVEEDOR)
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

                  // 2. CONTENIDO INFERIOR CON DATOS ENLAZADOS A RIVERPOD
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

                        // Enlazamos tu BotonEmergencia a los datos del proveedor
                        BotonEmergencia(
                          texto: "AVISOS METEOROLÓGICOS",
                          subtexto: climaEstado.subtextoAvisos,
                          colorAccento: climaEstado.colorAvisosSMN,
                          icono: climaEstado.iconoAvisos,
                          onTap: _abrirAlertasSMN,
                        ),

                        const SizedBox(height: 16),

                        // Segundo botón enlazado a las Alertas Críticas del proveedor
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