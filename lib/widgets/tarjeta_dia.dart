//Maneja el Pronóstico Extendido
import 'package:flutter/material.dart';
import 'package:app_clima_01/config/app_theme.dart';

class TarjetaDia extends StatelessWidget {
  final String dia;
  final IconData icono;
  final String temp;
  final String estado;
  final VoidCallback onTap;

  const TarjetaDia({
    super.key,
    required this.dia,
    required this.icono,
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
          height: 135,
          margin: const EdgeInsets.only(right: 14),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.cardSurface.withAlpha(153),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(dia, style: AppTheme.forecastLabel),
              const SizedBox(height: 8),
              Icon(icono, color: Colors.lightBlue.shade200, size: 28),
              const SizedBox(height: 8),
              Text(temp, style: AppTheme.forecastTemp),
              const SizedBox(height: 6),
              Text(
                estado,
                style: AppTheme.forecastStatus,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
