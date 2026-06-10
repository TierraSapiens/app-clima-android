import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_clima_01/config/app_theme.dart';
import 'package:app_clima_01/models/clima_model.dart';
import 'package:app_clima_01/utils/conversores_clima.dart';
import 'package:app_clima_01/views/favoritos/favoritos_controller.dart';

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
  Widget build(BuildContext context, WidgetRef ref) {
    final listaFavoritos = ref.watch(favoritosProvider).value ?? [];
    final bool esFavorita = listaFavoritos.any(
      (ciu) => ciu.nombre.toLowerCase() == localidad.toLowerCase(),
    );

    return Container(
      constraints: const BoxConstraints(minHeight: 360),
      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 15.0),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 1),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    localidad,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.title.copyWith(
                      fontSize: 28,
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
                ),
                const SizedBox(width: 10),

                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    esFavorita ? Icons.favorite : Icons.favorite_border,
                    color: esFavorita ? Colors.red : Colors.white,
                    size: 28,
                  ),
                  onPressed: () {
                    ref
                        .read(favoritosProvider.notifier)
                        .alternarFavorito(localidad, lat, lon);
                  },
                ),
              ],
            ),

            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  obtenerRutaImagenClima(respuesta.codigoIcono),
                  width: 145,
                  height: 145,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 20),
                Text(
                  '${respuesta.temperatura}°',
                  style: const TextStyle(
                    fontSize: 115,
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
            const SizedBox(height: 40),
            Text(
              '${respuesta.estado}  •  Sensación térmica ${respuesta.sensacionTermica}°',
              style: AppTheme.subtitle.copyWith(
                fontSize: 18,
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
