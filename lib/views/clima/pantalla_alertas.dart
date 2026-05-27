import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // <-- La nueva librería nativa

class PantallaAlertas extends StatefulWidget {
  const PantallaAlertas({super.key});

  @override
  State<PantallaAlertas> createState() => _PantallaAlertasState();
}

class _PantallaAlertasState extends State<PantallaAlertas> {
  // Coordenadas para que el mapa abra centrado justo en Argentina
  static const CameraPosition _puntoCentralArgentina = CameraPosition(
    target: LatLng(-40.000000, -64.000000), 
    zoom: 4.2, // Zoom ideal para ver el territorio completo en la pantalla
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema de Alertas'),
        backgroundColor: const Color(0xFF1A237E), // Un azul oscuro bien prolijo
      ),
      body: const GoogleMap(
        initialCameraPosition: _puntoCentralArgentina,
        mapType: MapType.normal,
        myLocationEnabled: true,       // Muestra el puntito azul de la ubicación del usuario
        myLocationButtonEnabled: true, // Habilita el botón nativo para centrar en tu ubicación
        zoomControlsEnabled: false,    // Desactivamos los botones [+] y [-] para que quede limpio y moderno
      ),
    );
  }
}