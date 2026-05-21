//Maneja el Pronóstico Extendido
import 'package:flutter/material.dart';

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
            color: const Color(0xFF1E293B).withAlpha(153),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(dia, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white60)),
              const SizedBox(height: 8),
              Icon(icono, color: Colors.lightBlue.shade200, size: 28),
              const SizedBox(height: 8),
              Text(temp, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                estado,
                style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w400),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
