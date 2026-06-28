import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Importante: agregamos Riverpod acá también
import 'configuracion_controller.dart';

// 1. Cambiamos StatefulWidget por ConsumerWidget
class PantallaConfiguracion extends ConsumerWidget {
  const PantallaConfiguracion({super.key});

  @override
  // 2. Le agregamos "WidgetRef ref" al build para poder escuchar a Riverpod
  Widget build(BuildContext context, WidgetRef ref) {
    const colorFondo = Color(0xFF121826); 
    const colorTarjeta = Color(0xFF1E2638);
    final colorAcento = Theme.of(context).primaryColor; 

    // 3. ¡Magia! Escuchamos los datos en tiempo real con una sola línea
    final config = ref.watch(configuracionProvider);

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text('Configuración', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      // 4. Voló el AnimatedBuilder. Ahora mandamos el ListView directo.
      body: ListView(
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
                      // 5. Usamos ref.read para mandarle la orden al controlador
                      onChanged: (nueva) => ref.read(configuracionProvider.notifier).actualizarTemperatura(nueva),
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
                      onChanged: (nueva) => ref.read(configuracionProvider.notifier).actualizarViento(nueva),
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
                      onChanged: (nueva) => ref.read(configuracionProvider.notifier).actualizarPrecipitacion(nueva),
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
                      onChanged: (nueva) => ref.read(configuracionProvider.notifier).actualizarPresion(nueva),
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
                    activeThumbColor: Colors.greenAccent, 
                    activeTrackColor: Colors.greenAccent.withValues(alpha: 0.3), 
                    inactiveThumbColor: Colors.grey.shade400,
                    inactiveTrackColor: Colors.white10,
                    onChanged: (activo) => ref.read(configuracionProvider.notifier).actualizarAlertasLocales(activo),
                  ),
                ],
              ),
            ),
          ),
        ],
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