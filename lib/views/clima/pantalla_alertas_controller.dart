import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class PantallaAlertasController extends ChangeNotifier {
  int _diaSeleccionado = 1;
  int get diaSeleccionado => _diaSeleccionado;

  final List<Polygon> _poligonos = [];
  List<Polygon> get poligonos => _poligonos;

  PantallaAlertasController() {
    _generarPoligonosDePrueba();
  }

  void cambiarDia(int nuevoDia) {
    _diaSeleccionado = nuevoDia;
    _generarPoligonosDePrueba();
    notifyListeners();
  }

  void _generarPoligonosDePrueba() {
    _poligonos.clear();

    Color colorZonaCentro;
    Color colorZonaSur;

    if (_diaSeleccionado == 1) {
      colorZonaCentro = Colors.amber;       // Alerta Amarilla
      colorZonaSur = Colors.green;          // Sin Alerta (Verde)
    } else if (_diaSeleccionado == 2) {
      colorZonaCentro = Colors.orange;      // Alerta Naranja
      colorZonaSur = Colors.amber;          // Alerta Amarilla
    } else {
      colorZonaCentro = Colors.green;       // Sin Alerta (Verde)
      colorZonaSur = Colors.red;            // Alerta Roja
    }

    // 1. Zona Centro
    _poligonos.add(
      Polygon(
        points: [
          LatLng(-30.0, -64.0),
          LatLng(-30.0, -59.0),
          LatLng(-36.0, -59.0),
          LatLng(-36.0, -64.0),
        ],
        color: colorZonaCentro.withAlpha(70),
        borderColor: colorZonaCentro,
        borderStrokeWidth: 2,
      ),
    );

    // 2. Zona Sur
    _poligonos.add(
      Polygon(
        points: [
          LatLng(-40.0, -71.0),
          LatLng(-40.0, -64.0),
          LatLng(-48.0, -66.0),
          LatLng(-48.0, -72.0),
        ],
        color: colorZonaSur.withAlpha(70),
        borderColor: colorZonaSur,
        borderStrokeWidth: 2,
      ),
    );
  }
}