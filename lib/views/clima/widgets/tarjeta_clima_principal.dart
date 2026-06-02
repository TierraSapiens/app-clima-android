import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 👈 NUEVO: Para que funcione Riverpod
import 'package:app_clima_01/config/app_theme.dart';
import 'package:app_clima_01/models/clima_model.dart';
import 'package:app_clima_01/utils/conversores_clima.dart';
import 'package:app_clima_01/views/favoritos/favoritos_controller.dart'; // 👈 NUEVO: Para controlar tus favoritos

// 🔄 CAMBIAMOS StatelessWidget por ConsumerWidget para activar Riverpod en la tarjeta
class TarjetaClimaPrincipal extends ConsumerWidget {
  final String localidad;
  final ClimaRespuesta respuesta;
  final double lat;        
  final double lon;

  const TarjetaClimaPrincipal({
    super.key,
    required this.localidad,
    required this.respuesta,
    required this.lat, 
    required this.lon,
  });

  @override
  // ✨ Ahora "WidgetRef ref" es válido y funciona perfectamente
  Widget build(BuildContext context, WidgetRef ref) {
    
    // 📡 Escuchamos la lista de favoritos guardada en el almacenamiento del teléfono
    final listaFavoritos = ref.watch(favoritosProvider).value ?? [];
    
    // ❤️ Evaluamos en tiempo real si esta ciudad ya está guardada en favoritos
    final bool esFavorita = listaFavoritos.any(
      (ciu) => ciu.nombre.toLowerCase() == localidad.toLowerCase()
    );

    return Container(
      constraints: const BoxConstraints(minHeight: 380),
      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 24.0),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            
            // 📍 FILA NUEVA: Nombre de la ciudad + Botón interactivo de Corazón
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  localidad,
                  style: AppTheme.title.copyWith(
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    shadows: [
                      const Shadow(
                        blurRadius: 8.0,
                        color: Colors.black45,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10), // Espacio de separación horizontal con el corazón
                
                // 🪙 EL BOTÓN DEL CORAZÓN (Tal cual tus diseños Movil37c y d)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    esFavorita ? Icons.favorite : Icons.favorite_border,
                    color: esFavorita ? Colors.red : Colors.white, // Se pone rojo si es favorita
                    size: 28, // Tamaño ideal alineado al texto grande
                  ),
                  onPressed: () {
                    // Agrega o quita de la base de datos local sin interferir con el clima
                    ref.read(favoritosProvider.notifier).alternarFavorito(localidad, lat, lon);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  obtenerRutaImagenClima(respuesta.codigoIcono),
                  width: 140,
                  height: 140,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 10),
                Text(
                  '${respuesta.temperatura}°',
                  style: const TextStyle(
                    fontSize: 110,
                    fontWeight: FontWeight.w100,
                    letterSpacing: -8,
                    height: 0.85,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black38,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${respuesta.estado}  •  Sensación térmica ${respuesta.sensacionTermica}°',
              style: AppTheme.subtitle.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
                shadows: [
                  const Shadow(
                    blurRadius: 6.0,
                    color: Colors.black45,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}