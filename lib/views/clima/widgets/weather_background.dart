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
    if (codigo.endsWith('n')) {
      if (codigo.startsWith('01'))
        return 'assets/images/cielo_noche_despejado.jpg';
      if (codigo.startsWith('02') ||
          codigo.startsWith('03') ||
          codigo.startsWith('04'))
        return 'assets/images/cielo_noche_nublado.jpg';
      return 'assets/images/cielo_noche_lluvia.jpg';
    } else {
      if (codigo.startsWith('01'))
        return 'assets/images/cielo_dia_despejado.jpg';
      if (codigo.startsWith('02') ||
          codigo.startsWith('03') ||
          codigo.startsWith('04'))
        return 'assets/images/cielo_dia_nublado.jpg';
      return 'assets/images/cielo_dia_lluvia.jpg';
    }
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
          child: Container(color: Colors.black.withValues(alpha: 0.35)),
        ),

        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.5),
                  Colors.black,
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          ),
        ),

        Positioned.fill(child: child),
      ],
    );
  }
}
