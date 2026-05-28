import 'package:flutter/material.dart';

class PantallaAlertasController extends ChangeNotifier {
  int _diaSeleccionado = 1; // 1 = Lunes/Hoy, 2 = Martes, 3 = Miércoles
  int get diaSeleccionado => _diaSeleccionado;

  String _urlCapaSmn = '';
  String get urlCapaSmn => _urlCapaSmn;

  PantallaAlertasController() {
    _definirCapaSmn();
  }

  void cambiarDia(int nuevoDia) {
    _diaSeleccionado = nuevoDia;
    _definirCapaSmn(); 
    notifyListeners();  
  }

  void _definirCapaSmn() {
    if (_diaSeleccionado == 1) {
      _urlCapaSmn = 'http://mapa.smn.gob.ar/mapcache/tms/1.0.0/argentina_smn_3857_alertas@GoogleMapsCompatible/{z}/{x}/{-y}.png';
    } else if (_diaSeleccionado == 2) {
      _urlCapaSmn = 'http://mapa.smn.gob.ar/mapcache/tms/1.0.0/argentina_smn_3857_alertas_dia2@GoogleMapsCompatible/{z}/{x}/{-y}.png';
    } else {
      _urlCapaSmn = 'http://mapa.smn.gob.ar/mapcache/tms/1.0.0/argentina_smn_3857_alertas_dia3@GoogleMapsCompatible/{z}/{x}/{-y}.png';
    }
  }
}