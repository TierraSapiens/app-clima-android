import 'package:flutter/material.dart';
import 'package:app_clima_01/config/app_theme.dart';

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
          border: Border.all(color: colorAccento.withAlpha(102), width: 1.5),
        ),
        child: Row(
          children: [
            // 1. Ícono
            Icon(icono, color: colorAccento, size: 32),
            const SizedBox(width: 16),
            
            // 2. Título (AVISOS / ALERTAS)
            Text(
              texto,
              style: AppTheme.buttonTitle.copyWith(color: colorAccento),
            ),
            
            // 3. 🛑 ¡ACÁ REGULÁS LOS PÍXELES! 🛑
            // Cambiá este 40 por el número que quieras (30, 50, 65...) para alejarlo a tu gusto
            const SizedBox(width: 45), 
            
            // 4. El Subtexto (Vuelve a alinearse a la izquierda normal)
            Expanded(
              child: Text(
                subtexto,
                textAlign: TextAlign.start, // 👈 Volvió a la izquierda
                style: TextStyle(
                  fontSize: 14,
                  color: colorSubtexto,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // 5. Flechita >
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