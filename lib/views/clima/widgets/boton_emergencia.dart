import 'package:flutter/material.dart';
import 'package:app_clima_01/config/app_theme.dart';
import 'package:marquee/marquee.dart'; // 👈 1. IMPORTANTE: Agregamos este import

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
        
        // 🛠️ MODIFICÁ ESTA LÍNEA PARA EL CONTORNO:
        border: Border.all(
          color: colorAccento, // 👈 Quitale el '.withAlpha(102)' para que el borde brille con el color puro (verde o naranja)
          width: 2.0,          // 👈 BOTON borde AVISO y ALERTA Subilo a 2.0 o 2.5 si querés un contorno más marcado y grueso
        ),
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
            
            // 3. Espaciado intermedio
            const SizedBox(width: 15), 
            // MARQUESINA ANIMADA!
            Expanded(
              child: SizedBox(
                height: 20, // 👈 Se necesita una altura fija para que Marquee funcione dentro de una Fila
                child: Marquee(
                  text: subtexto,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorSubtexto,
                  ),
                  scrollAxis: Axis.horizontal, // Movimiento horizontal de derecha a izquierda
                  crossAxisAlignment: CrossAxisAlignment.start,
                  blankSpace: 40.0, // El espacio en blanco que queda antes de que la frase vuelva a empezar
                  velocity: 25.0, // La velocidad del cartel (más alto = más rápido)
                  pauseAfterRound: const Duration(seconds: 2), // Se frena 2 segundos cada vez que termina de mostrar la frase entera
                  accelerationDuration: const Duration(seconds: 1),
                  accelerationCurve: Curves.linear,
                ),
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