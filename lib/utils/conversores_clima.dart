import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Map<String, dynamic> mapearClimaOpenWeather(String condicion) {
  if (condicion == 'Clear') {
    return {'icono': Icons.wb_sunny_rounded, 'color': const Color(0xFFFCD34D)};
  } else if (condicion == 'Clouds') {
    return {'icono': Icons.wb_cloudy_rounded, 'color': const Color(0xFF94A3B8)};
  } else if (condicion == 'Rain' || condicion == 'Drizzle') {
    return {'icono': Icons.umbrella_rounded, 'color': const Color(0xFF60A5FA)};
  } else if (condicion == 'Thunderstorm') {
    return {'icono': Icons.thunderstorm_rounded, 'color': const Color(0xFFA855F7)};
  } else {
    return {'icono': Icons.cloud_queue_rounded, 'color': Colors.white70};
  }
}

Map<String, dynamic> traducirCodigoWMO(int codigo) {
  if (codigo == 0) {
    return {'icono': Icons.wb_sunny_rounded, 'color': const Color(0xFFFCD34D), 'texto': 'Soleado'};
  } else if (codigo >= 1 && codigo <= 3) {
    return {'icono': Icons.wb_cloudy_rounded, 'color': const Color(0xFF94A3B8), 'texto': 'Sol y nubes'};
  } else if ((codigo >= 51 && codigo <= 67) || (codigo >= 80 && codigo <= 82)) {
    return {'icono': Icons.umbrella_rounded, 'color': const Color(0xFF60A5FA), 'texto': 'Lluvia probable'};
  } else if (codigo >= 95 && codigo <= 99) {
    return {'icono': Icons.thunderstorm_rounded, 'color': const Color(0xFFA855F7), 'texto': 'Tormenta eléctrica'};
  } else {
    return {'icono': Icons.cloud_queue_rounded, 'color': Colors.white70, 'texto': 'Nublado'};
  }
}

IconData obtenerIconoPorCodigo(String codigoIconoApi) {
  return codigoIconoApi.endsWith('n') ? Icons.nightlight_round : Icons.wb_sunny;
}

String formatearLabelPronostico(DateTime fecha) {
  final diaSemana = DateFormat('EEE', 'es_AR').format(fecha).toUpperCase().replaceAll('.', '');
  final diaMes = DateFormat('dd/MM').format(fecha);
  return '$diaSemana. $diaMes';
}

String capitalizarPrimeraLetra(String texto) {
  if (texto.isEmpty) return texto;
  return texto[0].toUpperCase() + texto.substring(1);
}
