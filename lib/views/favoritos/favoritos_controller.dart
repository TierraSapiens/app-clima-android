import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 📍 Modelo simple para guardar los datos de la ciudad favorita
class LocalidadFavorita {
  final String nombre;
  final double lat;
  final double lon;

  LocalidadFavorita({required this.nombre, required this.lat, required this.lon});

  Map<String, dynamic> toMap() => {'nombre': nombre, 'lat': lat, 'lon': lon};
  
  factory LocalidadFavorita.fromMap(Map<String, dynamic> map) => LocalidadFavorita(
        nombre: map['nombre'],
        lat: map['lat'] is int ? (map['lat'] as int).toDouble() : map['lat'],
        lon: map['lon'] is int ? (map['lon'] as int).toDouble() : map['lon'],
      );
}

/// 🎛️ Controlador con Riverpod y persistencia local
final favoritosProvider = AsyncNotifierProvider<FavoritosNotifier, List<LocalidadFavorita>>(() {
  return FavoritosNotifier();
});

class FavoritosNotifier extends AsyncNotifier<List<LocalidadFavorita>> {
  late SharedPreferences _prefs;

  @override
  Future<List<LocalidadFavorita>> build() async {
    _prefs = await SharedPreferences.getInstance();
    // Leemos la lista guardada en el almacenamiento del teléfono
    final List<String>? listaJson = _prefs.getStringList('localidades_favoritas');
    if (listaJson == null) return [];
    
    return listaJson.map((item) => LocalidadFavorita.fromMap(json.decode(item))).toList();
  }

  /// 🔄 Agrega o quita una ciudad de favoritos (Toggle)
  Future<void> alternarFavorito(String nombre, double lat, double lon) async {
    final listaActual = state.value ?? [];
    // Verificamos si ya existe por nombre
    final existe = listaActual.any((ciu) => ciu.nombre.toLowerCase() == nombre.toLowerCase());

    List<LocalidadFavorita> nuevaLista;
    if (existe) {
      // Si ya existía, la removemos
      nuevaLista = listaActual.where((ciu) => ciu.nombre.toLowerCase() != nombre.toLowerCase()).toList();
    } else {
      // Si no existía, la sumamos a la lista
      nuevaLista = [...listaActual, LocalidadFavorita(nombre: nombre, lat: lat, lon: lon)];
    }

    // Actualizamos el estado de Riverpod de inmediato para refrescar la UI
    state = AsyncValue.data(nuevaLista);

    // Grabamos la nueva lista en el teléfono convertida a texto string
    final listaJson = nuevaLista.map((ciu) => json.encode(ciu.toMap())).toList();
    await _prefs.setStringList('localidades_favoritas', listaJson);
  }
}