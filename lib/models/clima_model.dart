import 'package:flutter/material.dart';

class ClimaDia {
  final String fechaLabel;
  final IconData icono;
  final Color colorIcono;
  final String tempMaxMin;
  final String estado;
  final String imagenAsset;

  ClimaDia({
    required this.fechaLabel,
    required this.icono,
    required this.colorIcono,
    required this.imagenAsset,
    required this.tempMaxMin,
    required this.estado,
  });
}

class ClimaRespuesta {
  final int temperatura;
  final int sensacionTermica;
  final String estado;
  final String codigoIcono;
  final String climaPrincipal;
  final IconData iconoActual;
  final Color colorIconoActual;
  final List<ClimaDia> pronostico;
  final int nivelAlerta;

  ClimaRespuesta({
    required this.temperatura,
    required this.sensacionTermica,
    required this.estado,
    required this.codigoIcono,
    required this.climaPrincipal,
    required this.iconoActual,
    required this.colorIconoActual,
    required this.pronostico,
    required this.nivelAlerta,
  });
}
