import 'package:flutter/material.dart';

class ClimaDia {
  final String fechaLabel;
  final IconData icono;
  final Color colorIcono;
  final String tempMaxMin;
  final String estado;

  ClimaDia({
    required this.fechaLabel,
    required this.icono,
    required this.colorIcono,
    required this.tempMaxMin,
    required this.estado,
  });
}