import 'package:flutter/material.dart';

class MapUtils {
  static Color getColorPorNivel(int nivel) {
    switch (nivel) {
      case 3: 
        return Colors.red.withValues(alpha: 0.6);    // Rojo
      case 2: 
        return Colors.orange.withValues(alpha: 0.6); // Naranja
      case 1: 
        return Colors.yellow.withValues(alpha: 0.6); // Amarillo
      default: 
        return Colors.green.withValues(alpha: 0.3);  // Verde (Nivel 0)
    }
  }
}