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

  String _obtenerRutaFondo(String codigoIcono) {
    switch (codigoIcono) {
      case '01d':
        return 'assets/images/cielo_dia_despejado.jpg';
      case '01n':
        return 'assets/images/cielo_noche_despejado.jpg';
      case '02d':
      case '03d':
      case '04d':
        return 'assets/images/cielo_dia_nublado.jpg';
      case '02n':
      case '03n':
      case '04n':
        return 'assets/images/cielo_noche_nublado.jpg';
      case '09d':
      case '10d':
      case '11d':
        return 'assets/images/cielo_dia_lluvia.jpg';
      case '09n':
      case '10n':
      case '11n':
        return 'assets/images/cielo_noche_lluvia.jpg';
      default:
        return codigoIcono.endsWith('d')
            ? 'assets/images/cielo_dia_despejado.jpg'
            : 'assets/images/cielo_noche_despejado.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String rutaFondo = _obtenerRutaFondo(respuesta.codigoIcono);

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        image: DecorationImage(
          image: AssetImage(rutaFondo),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.35),
            BlendMode.srcOver,
          ),
        ),
      ),
      padding: const EdgeInsets.only(
        top: 40.0,
        bottom: 32.0,
        left: 16.0,
        right: 16.0,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  obtenerRutaImagenClima(respuesta.codigoIcono),
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 10),
                Text(
                  '${respuesta.temperatura}°',
                  style: const TextStyle(
                    fontSize: 110,
                    fontWeight: FontWeight.w100,
                    letterSpacing: -8,
                    height: 1.0,
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
            const SizedBox(height: 20),
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
