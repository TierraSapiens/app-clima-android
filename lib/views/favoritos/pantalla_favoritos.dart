import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'favoritos_controller.dart';
import '../clima/pantalla_clima_controller.dart'; // Para actualizar el clima de la Home

class PantallaFavoritos extends ConsumerWidget {
  const PantallaFavoritos({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritosEstado = ref.watch(favoritosProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Fondo oscuro como tu app
      appBar: AppBar(
        title: const Text('Mis Localidades', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: favoritosEstado.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
        data: (listaFavoritos) {
          if (listaFavoritos.isEmpty) {
            return const Center(
              child: Text(
                'No tenés localidades guardadas.\n¡Agregá una desde la pantalla principal!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: listaFavoritos.length,
            itemBuilder: (context, index) {
              final ciudad = listaFavoritos[index];
              return Card(
                color: Colors.white.withOpacity(0.05),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.amber),
                  title: Text(
                    ciudad.nombre,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    'Lat: ${ciudad.lat.toStringAsFixed(2)} | Lon: ${ciudad.lon.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white38),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () {
                      // Borra de favoritos
                      ref.read(favoritosProvider.notifier).alternarFavorito(ciudad.nombre, ciudad.lat, ciudad.lon);
                    },
                  ),
                  onTap: () {
                    // 💡 ACÁ LA MAGIA: 
                    // Cuando tocan la ciudad, deberías pasarle las coordenadas a tu climaProvider notifier
                    // Ejemplo teórico (tendrás que adaptarlo según los métodos de tu pantalla_clima_controller):
                    // ref.read(climaProvider.notifier).loadPorCoordenadas(ciudad.lat, ciudad.lon, ciudad.nombre);
                    
                    Navigator.pop(context); // Volvemos a la Home
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}