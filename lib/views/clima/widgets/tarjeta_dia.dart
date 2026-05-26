import 'package:flutter/material.dart';
import 'package:app_clima_01/config/app_theme.dart';

class TarjetaDia extends StatelessWidget {
  final String dia;
  final String imagenAsset;
  final Color colorIcono;
  final String temp;
  final String estado;
  final VoidCallback onTap;

  const TarjetaDia({
    super.key,
    required this.dia,
    required this.imagenAsset,
    required this.colorIcono,
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
          height: 145,
          margin: const EdgeInsets.only(right: 14),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          decoration: BoxDecoration(
            color: const Color(0xFF161618),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dia.toUpperCase(),
                style: AppTheme.forecastLabel.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  fontSize: 14, // 👈 Agrandamos un poco la fecha (ej: MAR. 26/05)
                ),
              ),
              const SizedBox(height: 10),
              Image.asset(
                imagenAsset,
                width: 55, //Tamaño icon pronostico (¡Ya quedó impecable!)
                height: 55,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              Text(
                temp,
                style: AppTheme.forecastTemp.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  fontSize: 19, // 👈 Subimos el tamaño de la temperatura (ej: 15° / 7°)
                ),
              ),
              const SizedBox(height: 6),
              Text(
                estado,
                style: AppTheme.forecastStatus.copyWith(
                  color: Colors.white60,
                  fontSize: 12, // 👈 Subimos a 12 para que "Sol y nubes" sea más legible
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
