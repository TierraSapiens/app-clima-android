import 'package:app_clima_01/views/clima/pantalla_clima_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'favoritos_controller.dart';
import 'package:app_clima_01/services/clima_service.dart';

class PantallaFavoritos extends ConsumerStatefulWidget {
  const PantallaFavoritos({super.key});

  @override
  ConsumerState<PantallaFavoritos> createState() => _PantallaFavoritosState();
}

class _PantallaFavoritosState extends ConsumerState<PantallaFavoritos> {
  final TextEditingController _searchController = TextEditingController();
  List<LocalidadFavorita> _resultadosBusqueda = [];
  bool _cargandoBusqueda = false;

  // 🔍 FUNCIÓN REAL CONECTADA A TU API
  Future<void> _buscarCiudadEnApi(String query) async {
    if (query.trim().length < 3) {
      setState(() => _resultadosBusqueda = []);
      return;
    }

    setState(() => _cargandoBusqueda = true);

    try {
      final climaService = ClimaService();
      final resultadosCrudos = await climaService.buscarCiudadesPorNombre(query);
      
      final listaConvertida = resultadosCrudos.map((item) {
        return LocalidadFavorita(
          nombre: item['nombre'],
          lat: item['lat'],
          lon: item['lon'],
        );
      }).toList();

      setState(() {
        _resultadosBusqueda = listaConvertida;
      });
    } catch (e) {
      debugPrint("Error en buscador de UI: $e");
    } finally {
      setState(() => _cargandoBusqueda = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favoritosEstado = ref.watch(favoritosProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('Mis Localidades', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (value) => _buscarCiudadEnApi(value),
              decoration: InputDecoration(
                hintText: 'Buscar ciudad (Ej: Mendoza)...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                          _buscarCiudadEnApi('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: Colors.white10, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: Colors.amber, width: 1),
                ),
              ),
            ),
          ),

          Expanded(
            child: _searchController.text.isNotEmpty
                ? _construirResultadosBusqueda()
                : _construirListaFavoritos(favoritosEstado),
          ),
        ],
      ),
    );
  }

  Widget _construirResultadosBusqueda() {
    if (_cargandoBusqueda) {
      return const Center(child: CircularProgressIndicator(color: Colors.amber));
    }

    if (_resultadosBusqueda.isEmpty) {
      return const Center(
        child: Text('No se encontraron ciudades', style: TextStyle(color: Colors.white38)),
      );
    }

    return ListView.builder(
      itemCount: _resultadosBusqueda.length,
      itemBuilder: (context, index) {
        final ciudadResult = _resultadosBusqueda[index];

        return ListTile(
          leading: const Icon(Icons.location_city, color: Colors.white70),
          title: Text(ciudadResult.nombre, style: const TextStyle(color: Colors.white)),
          subtitle: Text('Lat: ${ciudadResult.lat} | Lon: ${ciudadResult.lon}', style: const TextStyle(color: Colors.white38)),
          onTap: () {
            ref.read(climaProvider.notifier).cargarClima(ciudadResult.lat, ciudadResult.lon, ciudadResult.nombre);
            Navigator.pop(context);
          },
          trailing: Consumer(
            builder: (context, ref, child) {
              final favoritosAsync = ref.watch(favoritosProvider);
              final lista = favoritosAsync.value ?? [];
              final bool yaEsFavorito = lista.any((c) => c.lat == ciudadResult.lat && c.lon == ciudadResult.lon);

              return IconButton(
                icon: Icon(
                  yaEsFavorito ? Icons.favorite : Icons.favorite_border,
                  color: yaEsFavorito ? Colors.redAccent : Colors.white54,
                ),
                onPressed: () async {
                  await ref.read(favoritosProvider.notifier).alternarFavorito(
                    ciudadResult.nombre,
                    ciudadResult.lat,
                    ciudadResult.lon,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _construirListaFavoritos(AsyncValue<List<LocalidadFavorita>> favoritosEstado) {
    return favoritosEstado.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
      error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
      data: (listaFavoritos) {
        if (listaFavoritos.isEmpty) {
          return const Center(
            child: Text(
              'No tenés localidades guardadas.\n¡Buscá una arriba para agregar!',
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
              color: Colors.black.withValues(alpha: 0.5),
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
                    ref.read(favoritosProvider.notifier).alternarFavorito(ciudad.nombre, ciudad.lat, ciudad.lon);
                  },
                ),
                onTap: () {
                  ref.read(climaProvider.notifier).cargarClima(ciudad.lat, ciudad.lon, ciudad.nombre);
                  Navigator.pop(context);
                },
              ),
            );
          },
        );
      },
    );
  }
}