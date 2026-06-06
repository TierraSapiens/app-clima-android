import 'package:flutter/material.dart';

class WeatherBackground extends StatelessWidget {
  final String codigoIconoApi;
  final Widget child;

  const WeatherBackground({
    super.key,
    required this.codigoIconoApi,
    required this.child,
  });

  String _obtenerRutaImagen(String codigo) {
    // Dia despejado
    if (codigo == '01d') {
      return 'assets/images/cielo_dia_despejado.jpg';
    }
    // Noche despejada
    if (codigo == '01n') {
      return 'assets/images/cielo_noche_despejado.jpg';
    }
    // Nubes dia
    if (codigo.startsWith('02') ||
        codigo.startsWith('03') ||
        codigo.startsWith('04')) {
      return codigo.endsWith('d')
          ? 'assets/images/cielo_dia_nublado.jpg'
          : 'assets/images/cielo_noche_nublado.jpg';
    }
    // Lluvia / tormenta
    if (codigo.startsWith('09') ||
        codigo.startsWith('10') ||
        codigo.startsWith('11')) {
      return codigo.endsWith('d')
          ? 'assets/images/cielo_dia_lluvia.jpg'
          : 'assets/images/cielo_noche_lluvia.jpg';
    }

    return codigo.endsWith('d')
        ? 'assets/images/cielo_dia_despejado.jpg'
        : 'assets/images/cielo_noche_despejado.jpg';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            _obtenerRutaImagen(codigoIconoApi),
            fit: BoxFit.cover,
          ),
        ),

        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.18),
          ),
        ),

        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.35),
                  Colors.black.withValues(alpha: 0.75),
                ],
                stops: const [0.0, 0.65, 1.0],
              ),
            ),
          ),
        ),

        Positioned.fill(
          child: child,
        ),
      ],
    );
  }
}