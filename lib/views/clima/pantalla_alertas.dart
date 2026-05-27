import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PantallaAlertas extends StatefulWidget {
  const PantallaAlertas({super.key});

  @override
  State<PantallaAlertas> createState() => _PantallaAlertasState();
}

class _PantallaAlertasState extends State<PantallaAlertas> {
  static const CameraPosition _puntoCentralArgentina = CameraPosition(
    target: LatLng(-40.000000, -64.000000), 
    zoom: 4.2,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema de Alertas'),
        backgroundColor: const Color(0xFF1A237E),
      ),
      body: const GoogleMap(
        initialCameraPosition: _puntoCentralArgentina,
        mapType: MapType.normal,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: false,
      ),
    );
  }
}