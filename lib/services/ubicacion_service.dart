import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class UbicacionDatos {
  final double latitud;
  final double longitud;
  final String localidad;

  UbicacionDatos({
    required this.latitud,
    required this.longitud,
    required this.localidad,
  });
}

class UbicacionService {
  Future<UbicacionDatos> obtenerUbicacionActual() async {
    bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) {
      throw Exception("GPS apagado");
    }

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        throw Exception("Permiso denegado");
      }
    }

    if (permiso == LocationPermission.deniedForever) {
      throw Exception("Permisos denegados permanentemente");
    }

    try {
      Position? posicion = await Geolocator.getLastKnownPosition();

      if (posicion != null) {
        final antiguedad = DateTime.now().difference(posicion.timestamp);
        if (antiguedad.inHours > 6) {
          debugPrint("⏳ La ubicación guardada es vieja (${antiguedad.inHours}hs). Forzamos búsqueda fresca.");
          posicion = null; 
        }
      }

      posicion ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      ).timeout(const Duration(seconds: 6), onTimeout: () {
        throw Exception("El GPS tardó demasiado en responder");
      });

      String localidadDetectada = "Desconocido";

      try {
        List<Placemark> marcas = await placemarkFromCoordinates(
          posicion.latitude,
          posicion.longitude,
        );

        if (marcas.isNotEmpty) {
          Placemark lugar = marcas.first;
          localidadDetectada =
              lugar.locality ?? lugar.administrativeArea ?? "Desconocido";
        }
      } catch (e) {
        debugPrint("Error en geocoding (conversión de coordenadas): $e");
        localidadDetectada = "Mar del Plata"; 
      }

      return UbicacionDatos(
        latitud: posicion.latitude,
        longitud: posicion.longitude,
        localidad: localidadDetectada,
      );

    } catch (e) {
      debugPrint("Error interno en UbicacionService: $e");
      return UbicacionDatos(
        latitud: -38.0055, 
        longitud: -57.5426, 
        localidad: "Mar del Plata (Defecto)"
      );
    }
  }
}
