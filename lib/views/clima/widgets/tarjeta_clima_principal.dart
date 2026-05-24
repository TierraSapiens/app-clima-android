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

  // Función para determinar cuál de tus imágenes usar según el código de OpenWeatherMap
  String _obtenerRutaFondo(String codigoIcono) {
    switch (codigoIcono) {
      case '01d': // Cielo despejado día
        return 'assets/images/cielo_dia_despejado.jpg';
      case '01n': // Cielo despejado noche
        return 'assets/images/cielo_noche_despejado.jpg';
      case '02d': // Pocas nubes día
      case '03d': // Nubes dispersas día
      case '04d': // Nublado día
        return 'assets/images/cielo_dia_nublado.jpg';
      case '02n': // Pocas nubes noche
      case '03n': // Nubes dispersas noche
      case '04n': // Nublado noche
        return 'assets/images/cielo_noche_nublado.jpg';
      case '09d': // Lluvia ligera día
      case '10d': // Lluvia día
      case '11d': // Tormenta día
        return 'assets/images/cielo_dia_lluvia.jpg';
      case '09n': // Lluvia ligera noche
      case '10n': // Lluvia noche
      case '11n': // Tormenta noche
        return 'assets/images/cielo_noche_lluvia.jpg';
      default:
        // Respaldo por si llega un código raro de nieve (13) o niebla (50)
        return codigoIcono.endsWith('d') 
            ? 'assets/images/cielo_dia_despejado.jpg' 
            : 'assets/images/cielo_noche_despejado.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    // URL del icono a color que va superpuesto
    final String urlIconoClima = 'https://openweathermap.org/img/wn/${respuesta.codigoIcono}@4x.png';
    // Ruta de tu imagen de fondo local
    final String rutaFondo = _obtenerRutaFondo(respuesta.codigoIcono);

    return Container(
      width: double.infinity, // Obliga a la tarjeta a usar todo el ancho de la pantalla
      decoration: BoxDecoration(
        // Agregamos esquinas redondeadas inferiores para que se vea más premium antes del pronóstico
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        // Aquí cargamos tu imagen de fondo
        image: DecorationImage(
          image: AssetImage(rutaFondo),
          fit: BoxFit.cover, // Hace que la imagen cubra todo el contenedor sin deformarse
          // Agregamos un filtro oscuro sutil para que las letras blancas se sigan leyendo perfecto
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.35),
            BlendMode.srcOver,
          ),
        ),
      ),
      // Mantenemos el padding interno para los textos e iconos
      padding: const EdgeInsets.only(top: 40.0, bottom: 32.0, left: 16.0, right: 16.0),
      child: SafeArea(
        bottom: false, // Evita espacios extras abajo
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              localidad,
              style: AppTheme.title.copyWith(
                letterSpacing: 0.5,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                // Agregamos una sombra al texto para asegurar legibilidad sobre cualquier cielo
                shadows: [
                  const Shadow(blurRadius: 8.0, color: Colors.black45, offset: Offset(0, 2))
                ],
              ),
            ),
            const SizedBox(height: 15), 
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // El icono a color oficial flotando sobre el fondo de cielo
                Image.network(
                  urlIconoClima,
                  width: 110, 
                  height: 110,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      respuesta.iconoActual,
                      size: 80,
                      color: respuesta.colorIconoActual,
                    );
                  },
                ),
                const SizedBox(width: 10),
                Text(
                  '${respuesta.temperatura}°',
                  style: const TextStyle(
                    fontSize: 85, 
                    fontWeight: FontWeight.w600, 
                    letterSpacing: -4, 
                    height: 1.0, 
                    color: Colors.white,
                    shadows: [
                      Shadow(blurRadius: 10.0, color: Colors.black38, offset: Offset(0, 2))
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
                  const Shadow(blurRadius: 6.0, color: Colors.black45, offset: Offset(0, 1))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}