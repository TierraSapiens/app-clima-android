import 'package:flutter/material.dart';
import 'configuracion_controller.dart';

class PantallaConfiguracion extends StatefulWidget {
  const PantallaConfiguracion({super.key});

  @override
  State<PantallaConfiguracion> createState() => _PantallaConfiguracionState();
}

class _PantallaConfiguracionState extends State<PantallaConfiguracion> {
  final ConfiguracionController _controller = ConfiguracionController();

  @override
  Widget build(BuildContext context) {
    const colorFondo = Color(0xFF121826); 
    const colorTarjeta = Color(0xFF1E2638);
    final colorAcento = Theme.of(context).primaryColor; 

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text('Configuración', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.cargando) {
            return const Center(child: CircularProgressIndicator());
          }

          final config = _controller.configuracion;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const Text(
                'UNIDADES DE MEDIDA',
                style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
              const SizedBox(height: 12),

              Card(
                color: colorTarjeta,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      _buildFilaConfiguracion(
                        titulo: 'Temperatura',
                        selector: _buildSelectorSegmentado(
                          opciones: ['C', 'F'],
                          etiquetas: ['°C', '°F'],
                          valorSeleccionado: config.unidadTemperatura,
                          onChanged: (nueva) => _controller.actualizarTemperatura(nueva),
                          colorAcento: colorAcento,
                        ),
                      ),
                      const Divider(color: Colors.white10),

                      _buildFilaConfiguracion(
                        titulo: 'Velocidad del viento',
                        selector: _buildSelectorSegmentado(
                          opciones: ['km/h', 'mph', 'm/s'],
                          etiquetas: ['km/h', 'mph', 'm/s'],
                          valorSeleccionado: config.unidadViento,
                          onChanged: (nueva) => _controller.actualizarViento(nueva),
                          colorAcento: colorAcento,
                        ),
                      ),
                      const Divider(color: Colors.white10),

                      _buildFilaConfiguracion(
                        titulo: 'Precipitaciones',
                        selector: _buildSelectorSegmentado(
                          opciones: ['mm', 'in'],
                          etiquetas: ['mm', 'in'],
                          valorSeleccionado: config.unidadPrecipitacion,
                          onChanged: (nueva) => _controller.actualizarPrecipitacion(nueva),
                          colorAcento: colorAcento,
                        ),
                      ),
                      const Divider(color: Colors.white10),

                      _buildFilaConfiguracion(
                        titulo: 'Presión atmosférica',
                        selector: _buildSelectorSegmentado(
                          opciones: ['hPa', 'mb'],
                          etiquetas: ['hPa', 'mb'],
                          valorSeleccionado: config.unidadPresion,
                          onChanged: (nueva) => _controller.actualizarPresion(nueva),
                          colorAcento: colorAcento,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Divider(color: Colors.white24, thickness: 1), 
              const SizedBox(height: 16),

              const Text(
                'PREFERENCIAS DE NOTIFICACIONES',
                style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
              const SizedBox(height: 12),

              Card(
                color: colorTarjeta,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alertas climáticas en mi zona',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Recibí avisos inmediatos sobre tormentas o granizo donde te encuentres.',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: config.alertasLocalesActivas,
                        activeThumbColor: colorAcento,
                        activeTrackColor: colorAcento.withValues(alpha: 0.5),
                        onChanged: (activo) => _controller.actualizarAlertasLocales(activo),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilaConfiguracion({required String titulo, required Widget selector}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400)),
          selector,
        ],
      ),
    );
  }

  Widget _buildSelectorSegmentado({
    required List<String> opciones,
    required List<String> etiquetas,
    required String valorSeleccionado,
    required Function(String) onChanged,
    required Color colorAcento,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131924), 
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(opciones.length, (index) {
          final opcion = opciones[index];
          final etiqueta = etiquetas[index];
          final estaSeleccionado = opcion == valorSeleccionado;

          return GestureDetector(
            onTap: () => onChanged(opcion),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: estaSeleccionado ? colorAcento : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                etiqueta,
                style: TextStyle(
                  color: estaSeleccionado ? Colors.white : Colors.grey,
                  fontWeight: estaSeleccionado ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}