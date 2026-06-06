import 'package:flutter/material.dart';
import 'package:app_clima_01/config/app_theme.dart';
import 'package:marquee/marquee.dart';

class BotonEmergencia extends StatelessWidget {
  final String texto;
  final String subtexto;
  final Color colorAccento;
  final Color colorSubtexto;
  final IconData icono;
  final VoidCallback onTap;

  const BotonEmergencia({
    super.key,
    required this.texto,
    required this.subtexto,
    required this.colorAccento,
    required this.colorSubtexto,
    required this.icono,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
        color: AppTheme.buttonSurface.withAlpha(128),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorAccento,
          width: 2.0,
        ),
      ),
        child: Row(
          children: [
            Icon(icono, color: colorAccento, size: 32),
            const SizedBox(width: 16),
            
            Text(
              texto,
              style: AppTheme.buttonTitle.copyWith(color: colorAccento),
            ),
            
            const SizedBox(width: 15), 
            Expanded(
              child: SizedBox(
                height: 20,
                child: Marquee(
                  text: subtexto,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorSubtexto,
                  ),
                  scrollAxis: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  blankSpace: 40.0,
                  velocity: 25.0,
                  pauseAfterRound: const Duration(seconds: 2),
                  accelerationDuration: const Duration(seconds: 1),
                  accelerationCurve: Curves.linear,
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white12,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}