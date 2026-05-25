import 'package:flutter/material.dart';
import 'package:app_clima_01/config/app_theme.dart';

class BotonEmergencia extends StatelessWidget {
  final String texto;
  final String subtexto;
  final Color colorAccento;
  final IconData icono;
  final VoidCallback onTap;

  const BotonEmergencia({
    super.key,
    required this.texto,
    required this.subtexto,
    required this.colorAccento,
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
          border: Border.all(color: colorAccento.withAlpha(102), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icono, color: colorAccento, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    texto,
                    style: AppTheme.buttonTitle.copyWith(color: colorAccento),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtexto,
                    style: const TextStyle(fontSize: 12, color: Colors.white38),
                  ),
                ],
              ),
            ),
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
