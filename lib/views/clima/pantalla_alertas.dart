import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../global_widgets/menu_lateral.dart';
import 'pantalla_alertas_controller.dart';

class PantallaAlertas extends ConsumerWidget {
  const PantallaAlertas({super.key});

  // ⚠️ TU API KEY DE STADIA MAPS ACÁ:
  final String stadiaApiKey = '188431d7-8fa7-4a4f-bf8e-ea1bbb91da22';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el estado del controlador
    final alertasAsync = ref.watch(alertasControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Alertas'),
        backgroundColor: Colors.blueGrey,
        actions: [
          // Solucionado el problema de la actualización: botón manual directo
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(alertasControllerProvider.notifier).refrescarAlertas();
            },
          ),
        ],
      ),
      drawer: const MenuLateral(), // Integrado prolijamente con tu widget global
      body: alertasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error al cargar alertas: $err')),
        data: (listaZonas) {
          // ¡Acá ya tenemos las 171 zonas procesadas y listas!
          return FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(-38.416097, -63.616672), // Centro de Argentina
              initialZoom: 4.5,
            ),
            children: [
              // Capa base de Stadia Maps para evitar bloqueos
              TileLayer(
                urlTemplate: 'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}.png?api_key=$stadiaApiKey',
                userAgentPackageName: 'com.example.app_clima_01',
              ),
            ],
          );
        },
      ),
    );
  }
}