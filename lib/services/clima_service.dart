import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_clima_01/models/clima_model.dart';
import 'package:app_clima_01/utils/conversores_clima.dart';

class ClimaService {
  Future<ClimaRespuesta?> obtenerDatosClima(double lat, double lon) async {
    const String apiKey = "d1f3d163ba58ae2e5fe2e027b312e550";

    final urlActual = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=es'
    );

    final urlForecast = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=auto&forecast_days=4'
    );

    try {
      // Ejecutar las dos llamadas en paralelo para reducir tiempo total de espera
      final responses = await Future.wait([http.get(urlActual), http.get(urlForecast)]);
      final resActual = responses[0];
      final resForecast = responses[1];

      if (resActual.statusCode == 200 && resForecast.statusCode == 200) {
        final datosActual = jsonDecode(resActual.body);
        final datosMeteo = jsonDecode(resForecast.body);
        final datosDiarios = datosMeteo['daily'];

        final int temperaturaActual = datosActual['main']['temp'].round();
        final int sensacionTermicaActual = datosActual['main']['feels_like'].round();
        final String descripcionActual = datosActual['weather'][0]['description'];
        final String estadoActual = capitalizarPrimeraLetra(descripcionActual);
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
          String labelCompleto = formatearLabelPronostico(fechaParseada);

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