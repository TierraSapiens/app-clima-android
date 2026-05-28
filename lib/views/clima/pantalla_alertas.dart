import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'pantalla_alertas_controller.dart';

class PantallaAlertas extends StatefulWidget {
  const PantallaAlertas({super.key});

  @override
  State<PantallaAlertas> createState() => _PantallaAlertasState();
}

class _PantallaAlertasState extends State<PantallaAlertas> {
  final PantallaAlertasController _controller = PantallaAlertasController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Capa Base: MAPA LIBRE (OpenStreetMap)
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(-40.000000, -64.000000), // Centro de Argentina
              initialZoom: 4.2,
              maxZoom: 18,
              minZoom: 3,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.papat.appclima',
              ),
              PolygonLayer(
                polygons: _controller.poligonos,
              ),
            ],
          ),

          // 2. Capa Superior: Título Flotante
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(80),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Text(
                    'Meteorología Argentina',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Sistema de Alerta Temprana (SMN)',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          // 3. Capa Inferior: Botonera Flotante
          Positioned(
            bottom: 30,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBotonDia(1, "LUNES 18"),
                _buildBotonDia(2, "MARTES 19"),
                _buildBotonDia(3, "MIÉRCOLES 20"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonDia(int numeroDia, String texto) {
    final bool esActivo = _controller.diaSeleccionado == numeroDia;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: GestureDetector(
          onTap: () {
            _controller.cambiarDia(numeroDia);
          },
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: esActivo ? const Color(0xFFE65100) : Colors.black.withAlpha(180),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: esActivo ? Colors.transparent : Colors.white24, width: 1),
            ),
            child: Center(
              child: Text(
                texto,
                style: TextStyle(color: Colors.white, fontWeight: esActivo ? FontWeight.bold : FontWeight.normal, fontSize: 13),
              ),
            ),
          ),
        ),
      ),
    );
  }
}