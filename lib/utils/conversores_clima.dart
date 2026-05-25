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
    return {
      'icono': Icons.thunderstorm_rounded,
      'color': const Color(0xFFA855F7),
    };
  } else {
    return {'icono': Icons.cloud_queue_rounded, 'color': Colors.white70};
  }
}

Map<String, dynamic> traducirCodigoWMO(int codigo) {
  if (codigo == 0) {
    return {
      'icono': Icons.wb_sunny_rounded,
      'color': const Color(0xFFFCD34D),
      'texto': 'Soleado',
    };
  } else if (codigo >= 1 && codigo <= 3) {
    return {
      'icono': Icons.wb_cloudy_rounded,
      'color': const Color(0xFF94A3B8),
      'texto': 'Sol y nubes',
    };
  } else if ((codigo >= 51 && codigo <= 67) || (codigo >= 80 && codigo <= 82)) {
    return {
      'icono': Icons.umbrella_rounded,
      'color': const Color(0xFF60A5FA),
      'texto': 'Lluvia probable',
    };
  } else if (codigo >= 95 && codigo <= 99) {
    return {
      'icono': Icons.thunderstorm_rounded,
      'color': const Color(0xFFA855F7),
      'texto': 'Tormenta eléctrica',
    };
  } else {
    return {
      'icono': Icons.cloud_queue_rounded,
      'color': Colors.white70,
      'texto': 'Nublado',
    };
  }
}

IconData obtenerIconoPorCodigo(String codigoIconoApi) {
  return codigoIconoApi.endsWith('n') ? Icons.nightlight_round : Icons.wb_sunny;
}

String obtenerRutaImagenClima(String codigoApi) {
  switch (codigoApi) {
    case '01d':
      return 'assets/clima/cielo_dia_despejado.png';
    case '01n':
      return 'assets/clima/cielo_noche_despejado.png';
    case '02d':
      return 'assets/clima/cielo_dia_nubes_dispersas.png';
    case '02n':
      return 'assets/clima/cielo_noche_nubes_dispersas.png';
    case '03d':
      return 'assets/clima/cielo_dia_nublado_leve.png';
    case '03n':
      return 'assets/clima/cielo_noche_nublado_leve.png';
    case '04d':
      return 'assets/clima/cielo_dia_nublado.png';
    case '04n':
      return 'assets/clima/cielo_noche_nublado.png';
    case '09d':
      return 'assets/clima/cielo_dia_lluvia.png';
    case '09n':
      return 'assets/clima/cielo_noche_lluvia.png';
    case '10d':
      return 'assets/clima/cielo_dia_lluvia.png';
    case '10n':
      return 'assets/clima/cielo_noche_lluvia.png';
    case '11d':
      return 'assets/clima/cielo_dia_tormenta_electrica.png';
    case '11n':
      return 'assets/clima/cielo_noche_tormenta_electrica.png';
    case '13d':
      return 'assets/clima/cielo_dia_nublado.png';
    case '13n':
      return 'assets/clima/cielo_noche_nublado.png';
    case '50d':
      return 'assets/clima/cielo_dia_nublado.png';
    case '50n':
      return 'assets/clima/cielo_noche_nublado.png';
    default:
      return 'assets/clima/cielo_dia_nublado.png';
  }
}

String formatearLabelPronostico(DateTime fecha) {
  final diaSemana = DateFormat(
    'EEE',
    'es_AR',
  ).format(fecha).toUpperCase().replaceAll('.', '');
  final diaMes = DateFormat('dd/MM').format(fecha);
  return '$diaSemana. $diaMes';
}

String capitalizarPrimeraLetra(String texto) {
  if (texto.isEmpty) {
    return texto;
  }
  return texto[0].toUpperCase() + texto.substring(1);
}

String obtenerRutaImagenPorWMO(int codigoWMO) {
  if (codigoWMO == 0) {
    return 'assets/clima/cielo_dia_despejado.png';
  }
  if (codigoWMO >= 1 && codigoWMO <= 3) {
    return 'assets/clima/cielo_dia_nubes_dispersas.png';
  }
  if (codigoWMO >= 51 && codigoWMO <= 55) {
    return 'assets/clima/cielo_dia_Llovizna.png';
  }
  if (codigoWMO >= 56 && codigoWMO <= 67) {
    return 'assets/clima/cielo_dia_lluvia.png';
  }
  if ((codigoWMO >= 61 && codigoWMO <= 67) ||
      (codigoWMO >= 80 && codigoWMO <= 82)) {
    return 'assets/clima/cielo_dia_lluvia.png';
  }
  if (codigoWMO >= 95 && codigoWMO <= 99) {
    return 'assets/clima/cielo_dia_tormenta_electrica.png';
  }
  if (codigoWMO == 71 ||
      codigoWMO == 73 ||
      codigoWMO == 75 ||
      codigoWMO == 77 ||
      codigoWMO == 85 ||
      codigoWMO == 86) {
    return 'assets/clima/cielo_dia_nublado.png';
  }
  return 'assets/clima/cielo_dia_nublado.png';
}
