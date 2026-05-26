import 'package:flutter/material.dart';
import 'package:app_clima_01/config/app_theme.dart';
import 'package:app_clima_01/models/clima_model.dart';
import 'package:app_clima_01/utils/conversores_clima.dart';

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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            respuesta.colorIconoActual.withValues(alpha: 0.2),
            Colors.transparent,
          ],
        ),
      ),
      constraints: const BoxConstraints(minHeight: 380), // 👈 Le da un piso de altura para que respire
      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 24.0), // 👈 Subí el padding de abajo de 12 a 24
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 👈 Centra todo el bloque verticalmente
          children: [
            const SizedBox(height: 20), // 👈 Le da un respiro inicial respecto al borde superior
            Text(
              localidad,
              style: AppTheme.title.copyWith(
                letterSpacing: 0.5,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                shadows: [
                  const Shadow(
                    blurRadius: 8.0,
                    color: Colors.black45,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipOval(
                  child: Image.asset(
                    obtenerRutaImagenClima(respuesta.codigoIcono),
                    width: 140,  //Tamaño Icono Clima Principal
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${respuesta.temperatura}°',
                  style: const TextStyle(
                    fontSize: 110,
                    fontWeight: FontWeight.w100,
                    letterSpacing: -8,
                    height: 0.85,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black38,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${respuesta.estado}  •  Sensación térmica ${respuesta.sensacionTermica}°',
              style: AppTheme.subtitle.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
                shadows: [
                  const Shadow(
                    blurRadius: 6.0,
                    color: Colors.black45,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
