import 'package:flutter/material.dart';
import 'package:app_clima_01/config/app_theme.dart';

class TarjetaDia extends StatelessWidget {
  final String dia;
  final IconData icono;
  final Color colorIcono; // 💡 NUEVO: Recibe el color dinámico del clima (Sol/Luna/Nube)
  final String temp;
  final String estado;
  final VoidCallback onTap;

  const TarjetaDia({
    super.key,
    required this.dia,
    required this.icono,
    required this.colorIcono, // Se vuelve obligatorio para dar vida a la tarjeta
    required this.temp,
    required this.estado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: IntrinsicWidth(
        child: Container(
          height: 145, // 📐 Aumentamos ligeramente para que los textos respiren mejor
          margin: const EdgeInsets.only(right: 14),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          decoration: BoxDecoration(
            // ✨ MEJORA: Un gris sólido premium un poco más claro que el fondo negro de la app
            color: const Color(0xFF161618), 
            borderRadius: BorderRadius.circular(20), // Bordes más suaves y modernos
              border: Border.all(
              // 🔍 MEJORA: Borde con opacidad blanca que ayuda a recortar la tarjeta sobre el fondo oscuro
              color: Colors.white.withValues(alpha: 0.06), 
              width: 1.2,
            ),
            // 💡 OPCIONAL: Una sombra muy suave para despegar la tarjeta tridimensionalmente
              boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dia.toUpperCase(), // Se ve más estético y tipo "UI de clima" en mayúsculas
                style: AppTheme.forecastLabel.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              // ✨ MEJORA: El icono ahora usa el color dinámico que le pasas, no siempre celeste
              Icon(icono, color: colorIcono, size: 32), 
              const SizedBox(height: 10),
              Text(
                temp, 
                style: AppTheme.forecastTemp.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                estado,
                // ✨ MEJORA: Aseguramos que el texto descriptivo sea legible forzando un gris claro directo si es necesario
                style: AppTheme.forecastStatus.copyWith(
                  color: Colors.white60, 
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
