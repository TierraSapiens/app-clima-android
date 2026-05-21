import 'package:flutter/material.dart';
import 'package:app_clima_01/config/app_theme.dart';
import 'package:app_clima_01/models/clima_model.dart';

class TarjetaClimaPrincipal extends StatelessWidget {
  final String localidad;
  final ClimaRespuesta respuesta;

  const TarjetaClimaPrincipal({
    super.key,
    required this.localidad,
    required this.respuesta,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          localidad,
          style: AppTheme.title,
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(respuesta.iconoActual, size: 85, color: respuesta.colorIconoActual),
            const SizedBox(width: 25),
            Text(
              '${respuesta.temperatura}°',
              style: const TextStyle(fontSize: 95, fontWeight: FontWeight.bold, letterSpacing: -2),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          '${respuesta.estado} • Sensación térmica ${respuesta.sensacionTermica}°',
          style: AppTheme.subtitle,
        ),
      ],
    );
  }
}
