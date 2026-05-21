import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_clima_01/models/clima_model.dart';
import 'package:app_clima_01/services/clima_service.dart';
import 'package:app_clima_01/widgets/boton_emergencia.dart';
import 'package:app_clima_01/widgets/tarjeta_dia.dart';

class PantallaClima extends StatefulWidget {
  const PantallaClima({super.key});

  @override
  State<PantallaClima> createState() => _PantallaClimaState();
}

class _PantallaClimaState extends State<PantallaClima> {
  final ClimaService _climaService = ClimaService();
  String _localidadActual = "Buscando ubicación...";
  String _temperaturaActual = "--";
  String _sensacionTermica = "--";
  String _estadoClimaActual = "Cargando datos del cielo...";
  
  IconData _iconoClimaPrincipal = Icons.wb_cloudy_rounded;
  Color _colorIconoPrincipal = Colors.blue.shade200;

  Color _colorFondoSuperior = const Color(0xFF0F172A); 
  Color _colorFondoInferior = const Color(0xFF020617);

  List<ClimaDia> _pronosticoTresDias = [];

  double _latitudGuardada = 0.0;
  double _longitudGuardada = 0.0;

  String _subtextoAvisos = "Nivel Verde: Sin advertencias";
  String _subtextoAlertas = "Nivel Verde: Condiciones normales";
  
  Color _colorAvisosSMN = const Color(0xFF22C55E); 
  Color _colorAlertasSMN = const Color(0xFF22C55E); 

  IconData _iconoAvisos = Icons.check_circle_outline_rounded;
  IconData _iconoAlertas = Icons.shield_outlined;

  @override
  void initState() {
    super.initState();
    _calcularFondoPorEstacion();
    _obtenerUbicacionActual();
  }

  void _calcularFondoPorEstacion() {
    final ahora = DateTime.now();
    final mes = ahora.month;
    final dia = ahora.day;

    if ((mes == 3 && dia >= 21) || mes == 4 || mes == 5 || (mes == 6 && dia < 21)) {
      _colorFondoSuperior = const Color(0xFF1E1B18); 
      _colorFondoInferior = const Color(0xFF0A0500);
    } else if ((mes == 6 && dia >= 21) || mes == 7 || mes == 8 || (mes == 9 && dia < 21)) {
      _colorFondoSuperior = const Color(0xFF0F172A); 
      _colorFondoInferior = const Color(0xFF020617);
    } else if ((mes == 9 && dia >= 21) || mes == 10 || mes == 11 || (mes == 12 && dia < 21)) {
      _colorFondoSuperior = const Color(0xFF062419); 
      _colorFondoInferior = const Color(0xFF020C08);
    } else {
      _colorFondoSuperior = const Color(0xFF131A35); 
      _colorFondoInferior = const Color(0xFF030712);
    }
  }

  Future<void> _obtenerUbicacionActual() async {
    bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) {
      setState(() => _localidadActual = "GPS apagado");
      return;
    }

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        setState(() => _localidadActual = "Permiso denegado");
        return;
      }
    }

    try {
      Position posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );

      _latitudGuardada = posicion.latitude;
      _longitudGuardada = posicion.longitude;

      List<Placemark> marcas = await placemarkFromCoordinates(posicion.latitude, posicion.longitude);
      if (marcas.isNotEmpty) {
        Placemark lugar = marcas.first;
        setState(() {
          _localidadActual = lugar.locality ?? lugar.administrativeArea ?? "Desconocido";
        });
      }

      await _obtenerDatosDeAmbasAPIs(posicion.latitude, posicion.longitude);
    } catch (e) {
      setState(() => _localidadActual = "Error al buscar");
    }
  }

  Future<void> _obtenerDatosDeAmbasAPIs(double lat, double lon) async {
    try {
      final respuesta = await _climaService.obtenerDatosClima(lat, lon);
      if (respuesta == null) {
        setState(() => _estadoClimaActual = "No se pudieron cargar los datos");
        return;
      }

      setState(() {
        _temperaturaActual = "${respuesta.temperatura}";
        _sensacionTermica = "${respuesta.sensacionTermica}";
        _estadoClimaActual = respuesta.estado;
        _iconoClimaPrincipal = respuesta.iconoActual;
        _colorIconoPrincipal = respuesta.colorIconoActual;
        _pronosticoTresDias = respuesta.pronostico;

        if (respuesta.nivelAlerta == 2) {
          _colorAvisosSMN = const Color(0xFFF97316);
          _subtextoAvisos = "Zonas afectadas por lluvias intensas";
          _iconoAvisos = Icons.warning_amber_rounded;

          _colorAlertasSMN = const Color(0xFFEF4444);
          _subtextoAlertas = "Zonas críticas: Tormentas severas";
          _iconoAlertas = Icons.gpp_bad_rounded;
        } else if (respuesta.nivelAlerta == 1) {
          _colorAvisosSMN = const Color(0xFFF97316);
          _subtextoAvisos = "Zonas afectadas por chaparrones";
          _iconoAvisos = Icons.warning_amber_rounded;

          _colorAlertasSMN = const Color(0xFF22C55E);
          _subtextoAlertas = "No hay Alertas";
          _iconoAlertas = Icons.shield_outlined;
        } else {
          _colorAvisosSMN = const Color(0xFF22C55E);
          _subtextoAvisos = "No hay avisos";
          _iconoAvisos = Icons.check_circle_outline_rounded;

          _colorAlertasSMN = const Color(0xFF22C55E);
          _subtextoAlertas = "No hay Alertas";
          _iconoAlertas = Icons.shield_outlined;
        }
      });
    } catch (e) {
      setState(() => _estadoClimaActual = "Error al sincronizar radares");
    }
  }


  Future<void> _abrirGraficoDetallado() async {
    final String urlFormada = 'https://www.meteoblue.com/es/tiempo/semana/index/index?lat=$_latitudGuardada&lon=$_longitudGuardada';
    final Uri uri = Uri.parse(urlFormada);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Error al abrir navegador: $e");
    }
  }

  Future<void> _abrirAlertasSMN() async {
    final Uri uri = Uri.parse('https://www.smn.gob.ar/alertas');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Error al abrir alertas SMN: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_colorFondoSuperior, _colorFondoInferior],
            stops: const [0.0, 0.65],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                
                const SizedBox(height: 60), //Baja o sube el clima actual

// 1.CLIMA ACTUAL
                Column(
                  children: [
                    Text(
                      _localidadActual,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_iconoClimaPrincipal, size: 85, color: _colorIconoPrincipal),
                        const SizedBox(width: 25),
                        Text(
                          '$_temperaturaActual°',
                          style: const TextStyle(fontSize: 95, fontWeight: FontWeight.bold, letterSpacing: -2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$_estadoClimaActual • Sensación térmica $_sensacionTermica°',
                      style: const TextStyle(fontSize: 16, color: Colors.white60, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),

                const SizedBox(height: 60), //Baja o sube pronostico

//2. PRONÓSTICO DE 3 Dias
                _pronosticoTresDias.isEmpty
                    ? const Center(child: CircularProgressIndicator()) 
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: _pronosticoTresDias.map((diaInfo) {
                            return TarjetaDia(
                              dia: diaInfo.fechaLabel,
                              icono: diaInfo.icono,
                              temp: diaInfo.tempMaxMin,
                              estado: diaInfo.estado,
                              onTap: _abrirGraficoDetallado,
                            );
                          }).toList(),
                        ),
                      ),

                const SizedBox(height: 60), // Sube y Baja los carteles de Avisos y ALERTAS

//3.AVISOS Y ALERTAS, configuracion Semaforo de SMN
                Column(
                  children: [
                    BotonEmergencia(
                      texto: 'AVISOS METEOROLÓGICOS',
                      subtexto: _subtextoAvisos,
                      colorAccento: _colorAvisosSMN,
                      icono: _iconoAvisos,
                      onTap: _abrirAlertasSMN,
                    ),
                    const SizedBox(height: 14), //los dos botones estén más pegados entre sí bajar ese 14 a un 8 o 10
                    BotonEmergencia(
                      texto: 'ALERTAS CRÍTICAS',
                      subtexto: _subtextoAlertas,
                      colorAccento: _colorAlertasSMN,
                      icono: _iconoAlertas,
                      onTap: _abrirAlertasSMN,
                    ),
                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

}
