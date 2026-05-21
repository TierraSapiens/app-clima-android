import 'package:flutter/material.dart';

class WeatherBackground extends StatelessWidget {
  final String codigoIconoApi; // Recibe el código de OpenWeather (ej: '01d', '09n')
  final Widget child; // Aquí irá todo el contenido de tu pantalla (el Column con la temperatura)

  const WeatherBackground({
    super.key,
    required this.codigoIconoApi,
    required this.child,
  });

  // 🌆 Función helper que elige la imagen del cielo según el código de la API
  String _obtenerRutaImagen(String codigo) {
    if (codigo.endsWith('n')) {
      // Imágenes de Noche 🌙
      if (codigo.startsWith('01')) return 'assets/images/cielo_noche_despejado.jpg';
      if (codigo.startsWith('02') || codigo.startsWith('03') || codigo.startsWith('04')) return 'assets/images/cielo_noche_nublado.jpg';
      return 'assets/images/cielo_noche_lluvia.jpg'; // Para tormentas o chubascos nocturnos
    } else {
      // Imágenes de Día ☀️
      if (codigo.startsWith('01')) return 'assets/images/cielo_dia_despejado.jpg';
      if (codigo.startsWith('02') || codigo.startsWith('03') || codigo.startsWith('04')) return 'assets/images/cielo_dia_nublado.jpg';
      return 'assets/images/cielo_dia_lluvia.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🌌 Capa 1: La imagen de fondo dinámica que ocupa toda la pantalla
        Positioned.fill(
          child: Image.asset(
            _obtenerRutaImagen(codigoIconoApi),
            fit: BoxFit.cover,
          ),
        ),

        // 🖤 Capa 2: El Overlay oscuro transparente para que las letras blancas se lean perfecto
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.35), // Controla la oscuridad general aquí
          ),
        ),

        // 🎨 Capa 3: El Degradado inferior (Gradient abajo) para fusionar con el fondo negro de tu app
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.5),
                  Colors.black, // Se vuelve negro puro abajo del todo
                ],
                stops: const [0.0, 0.7, 1.0], // El degradado fuerte empieza a partir del 70% de la pantalla
              ),
            ),
          ),
        ),

        // 📱 Capa 4: Tu interfaz de usuario (Textos, nubes, pronósticos, etc.)
        Positioned.fill(
          child: child,
        ),
      ],
    );
  }
}