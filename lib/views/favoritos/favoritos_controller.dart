import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

final favoritosProvider = AsyncNotifierProvider<FavoritosNotifier, List<LocalidadFavorita>>(() {
  return FavoritosNotifier();
});

class FavoritosNotifier extends AsyncNotifier<List<LocalidadFavorita>> {
  late SharedPreferences _prefs;

  @override
  Future<List<LocalidadFavorita>> build() async {
    _prefs = await SharedPreferences.getInstance();
    final List<String>? listaJson = _prefs.getStringList('localidades_favoritas');
    if (listaJson == null) return [];
    
    return listaJson.map((item) => LocalidadFavorita.fromMap(json.decode(item))).toList();
  }

  Future<void> alternarFavorito(String nombre, double lat, double lon) async {
    final listaActual = state.value ?? [];
    final existe = listaActual.any((ciu) => ciu.nombre.toLowerCase() == nombre.toLowerCase());

    List<LocalidadFavorita> nuevaLista;
    if (existe) {
      nuevaLista = listaActual.where((ciu) => ciu.nombre.toLowerCase() != nombre.toLowerCase()).toList();
    } else {
      nuevaLista = [...listaActual, LocalidadFavorita(nombre: nombre, lat: lat, lon: lon)];
    }

    state = AsyncValue.data(nuevaLista);
    final listaJson = nuevaLista.map((ciu) => json.encode(ciu.toMap())).toList();
    await _prefs.setStringList('localidades_favoritas', listaJson);
  }
}