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
    return Container(
      // Un espaciado interno para albergar el resplandor cómodamente
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      decoration: BoxDecoration(
        // Genera un sutil degradado radial detrás del icono y la temperatura
        gradient: RadialGradient(
          center: const Alignment(0.0, 0.1), // Centrado levemente hacia abajo
          radius: 0.8,
          colors: [
            // Usa el color del icono con opacidad para el centro del resplandor
            respuesta.colorIconoActual.withValues(alpha: 0.12),
            Colors.transparent, // Se desvanece hacia el fondo negro de la app
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            localidad,
            style: AppTheme.title.copyWith(
              letterSpacing: 0.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20), // Un poco más de aire con la localidad
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // El icono con un tamaño imponente y estilizado
              Icon(
                respuesta.iconoActual, 
                size: 90, 
                color: respuesta.colorIconoActual,
              ),
              const SizedBox(width: 20),
              Text(
                '${respuesta.temperatura}°',
                style: const TextStyle(
                  fontSize: 100, // Un toque más grande para dar jerarquía
                  fontWeight: FontWeight.w600, // W600 suele verse más premium que bold puro en fuentes grandes
                  letterSpacing: -4, // Ajuste de kerning para números grandes
                  height: 1.0, // Evita espacios fantasma arriba y abajo del texto
                ),
              ),
            ],
          ),
          const SizedBox(height: 20), // Más separación antes del subtítulo
          Text(
            '${respuesta.estado}  •  Sensación térmica ${respuesta.sensacionTermica}°',
            style: AppTheme.subtitle.copyWith(
              color: Colors.white70, // Mayor contraste para facilitar la lectura
            ),
          ),
        ],
      ),
    );
  }
}
