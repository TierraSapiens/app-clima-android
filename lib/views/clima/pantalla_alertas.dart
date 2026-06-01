import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'pantalla_alertas_controller.dart';

class PantallaAlertas extends ConsumerWidget {
  const PantallaAlertas({super.key});
  final String stadiaApiKey = '188431d7-8fa7-4a4f-bf8e-ea1bbb91da22';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertasAsync = ref.watch(alertasControllerProvider);
    final indexDiaSeleccionado = ref.watch(diaSeleccionadoProvider);
    final ahora = DateTime.now();
    const diasSemana = ['', 'LUNES', 'MARTES', 'MIÉRCOLES', 'JUEVES', 'VIERNES', 'SÁBADO', 'DOMINGO'];

    return Scaffold(
      appBar: AppBar(
      title: const Text(
        'Alertas Meteorológicas',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: const Color(0xFFE65100), // 👈 El naranja que te gustó de Avisos
      iconTheme: const IconThemeData(color: Colors.white), // Flecha de volver blanca
      
      // 🔄 ACÁ ADENTRO CONSERVAMOS TU ACTUALIZADOR:
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            debugPrint("📡 Forzando reintento manual de alertas del SMN...");
            ref.invalidate(alertasControllerProvider);
          },
        ),
      ],
    ),
      body: Stack(
        children: [
          alertasAsync.when(
            loading: () => const Center(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Sintonizando alertas del SMN...', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
            error: (err, stack) => Center(
              child: Card(
                color: Colors.red.shade50,
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('❌ Error al cargar alertas: $err', style: TextStyle(color: Colors.red.shade900)),
                ),
              ),
            ),
            data: (listaZonas) {
              return FlutterMap(
                options: const MapOptions(
                  initialCenter: LatLng(-38.416097, -63.616672), // Centro de Argentina
                  initialZoom: 4.5,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}.png?api_key=$stadiaApiKey',
                    userAgentPackageName: 'com.example.app_clima_01',
                  ),
                  PolygonLayer(
                    polygons: listaZonas.map((zona) {
                      Color colorAlerta = const Color.fromARGB(255, 39, 137, 176);
                      
                      // Colores de la escala oficial del SMN:
                      // 1 = Verde, 2 = Amarillo, 3 = Naranja, 4 = Rojo
                      if (zona.maxLevel == 1) colorAlerta = const Color(0xFF35c795); // Estado normal
                      if (zona.maxLevel == 2) colorAlerta = Colors.amber;          // Alerta Amarilla
                      if (zona.maxLevel == 3) colorAlerta = Colors.orange;         // Alerta Naranja
                      if (zona.maxLevel == 4) colorAlerta = Colors.red;            // Alerta Roja

                      return Polygon(
                        points: List<LatLng>.from(zona.coordenadas),
                        // Se baja el alpha al verde (0.15) para que sea sutil y no sature, 
                        // y 0.4 para las alertas reales.
                        color: colorAlerta.withValues(alpha: zona.maxLevel == 1 ? 0.35 : 0.4),
                        borderStrokeWidth: zona.maxLevel == 1 ? 0.5 : 1.2,
                        borderColor: zona.maxLevel == 1 ? colorAlerta.withValues(alpha: 0.3) : colorAlerta,
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),

          // Botonera flotante de los 3 días
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(3, (index) {
                  //fecha correspondiente a cada botón (0: Hoy, 1: Mañana, 2: Pasado Mañana)
                  final fechaBoton = ahora.add(Duration(days: index));
                  final nombreDia = diasSemana[fechaBoton.weekday];
                  final numeroDia = fechaBoton.day;
                  final esActivo = indexDiaSeleccionado == index;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () {
                  // Al tocar el boton le avisa al controlador que cambie el dia
                          ref.read(alertasControllerProvider.notifier).seleccionarDia(index);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: esActivo ? Colors.blue.shade800 : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                index == 0 ? 'HOY' : nombreDia,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: esActivo ? Colors.white70 : Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$numeroDia',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: esActivo ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}