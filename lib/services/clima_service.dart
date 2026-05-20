import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:app_clima_01/models/clima_model.dart';

class ClimaService {
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
    if (codigoIconoApi.endsWith('n')) {
      return Icons.nightlight_round;
    }
    return Icons.wb_sunny;
  }

  Future<ClimaRespuesta?> obtenerDatosClima(double lat, double lon) async {
    const String apiKey = "d1f3d163ba58ae2e5fe2e027b312e550";

    final urlActual = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=es'
    );

    final urlForecast = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=auto&forecast_days=4'
    );

    try {
      final resActual = await http.get(urlActual);
      final resForecast = await http.get(urlForecast);

      if (resActual.statusCode == 200 && resForecast.statusCode == 200) {
        final datosActual = jsonDecode(resActual.body);
        final datosMeteo = jsonDecode(resForecast.body);
        final datosDiarios = datosMeteo['daily'];

        final int temperaturaActual = datosActual['main']['temp'].round();
        final int sensacionTermicaActual = datosActual['main']['feels_like'].round();
        final String descripcionActual = datosActual['weather'][0]['description'];
        final String estadoActual = descripcionActual.substring(0, 1).toUpperCase() + descripcionActual.substring(1);
        final String codigoIconoActual = datosActual['weather'][0]['icon'];
        final String climaPrincipal = datosActual['weather'][0]['main'];

        final IconData iconoActual = obtenerIconoPorCodigo(codigoIconoActual);
        final Color colorIconoActual = codigoIconoActual.endsWith('d')
            ? Colors.amber
            : Colors.blueGrey.shade100;

        List<ClimaDia> diasAfinados = [];
        int nivelMaximoAlerta = 0;

        for (int i = 1; i <= 3; i++) {
          String fechaRaw = datosDiarios['time'][i];
          DateTime fechaParseada = DateTime.parse(fechaRaw);

          String diaSemana = DateFormat('EEE', 'es_AR').format(fechaParseada).toUpperCase().replaceAll('.', '');
          String diaMes = DateFormat('dd/MM').format(fechaParseada);
          String labelCompleto = "$diaSemana. $diaMes";

          String max = "${datosDiarios['temperature_2m_max'][i].round()}°";
          String min = "${datosDiarios['temperature_2m_min'][i].round()}°";

          int codigoWMO = datosDiarios['weather_code'][i];

          if (codigoWMO == 96 || codigoWMO == 99 || codigoWMO == 65 || codigoWMO == 82) {
            if (nivelMaximoAlerta < 2) nivelMaximoAlerta = 2;
          } else if (codigoWMO == 95 || codigoWMO == 63 || codigoWMO == 81) {
            if (nivelMaximoAlerta < 1) nivelMaximoAlerta = 1;
          }

          var traduccion = traducirCodigoWMO(codigoWMO);

          diasAfinados.add(
            ClimaDia(
              fechaLabel: labelCompleto,
              icono: traduccion['icono'],
              colorIcono: traduccion['color'],
              tempMaxMin: "$max / $min",
              estado: traduccion['texto'],
            ),
          );
        }

        return ClimaRespuesta(
          temperatura: temperaturaActual,
          sensacionTermica: sensacionTermicaActual,
          estado: estadoActual,
          codigoIcono: codigoIconoActual,
          climaPrincipal: climaPrincipal,
          iconoActual: iconoActual,
          colorIconoActual: colorIconoActual,
          pronostico: diasAfinados,
          nivelAlerta: nivelMaximoAlerta,
        );
      }
    } catch (e) {
      debugPrint("Error en el servicio de clima: $e");
    }
    return null;
  }
}