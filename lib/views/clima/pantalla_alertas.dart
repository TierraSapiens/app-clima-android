import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:app_clima_01/views/clima/pantalla_alertas_controller.dart';

class PantallaAlertas extends StatefulWidget {
  const PantallaAlertas({super.key});

  @override
  State<PantallaAlertas> createState() => _PantallaAlertasState();
}

class _PantallaAlertasState extends State<PantallaAlertas> {
  final PantallaAlertasController _controller = PantallaAlertasController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Scaffold(
          body: Stack(
            children: [
              // 1 EL MAPA
              FlutterMap(
                options: const MapOptions(
                  initialCenter: LatLng(-38.416097, -63.616672), // Arg.
                  initialZoom: 4.5,
                  minZoom: 3.0,
                  maxZoom: 10.0,
                ),
                children: [
                  // Capa Base
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  ),
                  
                  // Capa alertas (Limpiaerrores)
                  TileLayer(
                    key: ValueKey(_controller.urlCapaSmn), 
                    urlTemplate: _controller.urlCapaSmn,
                  ),
                ],
              ),

              //2 ENCABEZADO ARRIBA (Gris translúcido)
              Positioned(
                top: 50.0,
                left: 20.0,
                right: 20.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        "Meteorología Argentina",
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Sistema de Alerta Temprana (SMN)",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),

              //3 BOTONES ABAJO (Días 1, 2 y 3)
              Positioned(
                bottom: 40.0,
                left: 12.0,
                right: 12.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(child: _buildBotonAbajo("LUNES 18", 1)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildBotonAbajo("MARTES 19", 2)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildBotonAbajo("MIÉRCOLES 20", 3)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBotonAbajo(String texto, int numeroDia) {
    final bool esActivo = _controller.diaSeleccionado == numeroDia;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: esActivo ? const Color(0xFFE65100) : const Color(0xFF37474F),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        elevation: 0,
      ),
      onPressed: () {
        _controller.cambiarDia(numeroDia);
      },
      child: Text(
        texto,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}