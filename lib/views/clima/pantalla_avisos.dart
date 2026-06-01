import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pantalla_avisos_controller.dart'; // Ajustá la ruta si está en otra carpeta

class PantallaAvisos extends StatelessWidget {
  const PantallaAvisos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Avisos a muy corto plazo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFE65100),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Botón de refresco manual usando un Consumer aislado
          Consumer(
            builder: (context, ref, _) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => ref.read(avisosControllerProvider.notifier).refrescarAvisos(),
              );
            },
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          // Escuchamos el estado reactivo del controlador de avisos
          final avisosAsync = ref.watch(avisosControllerProvider);

          return avisosAsync.when(
            // 1. Estado Cargando
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFFE65100)),
            ),
            // 2. Estado Error (Modo seguro / Servidor caído)
            error: (err, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'No se pudieron sincronizar los avisos.\nReintentá en unos minutos.',
                  style: TextStyle(color: Colors.red[300], fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // 3. Estado con Datos Exitosos
            data: (listaDeAvisos) {
              // Si la lista del SMN viene vacía (No hay tormentas a corto plazo)
              if (listaDeAvisos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 72, color: Colors.greenAccent[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'Sin avisos vigentes',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'El SMN no registra fenómenos severos\ninmediatos en este momento.',
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Si hay avisos activos, los listamos en Tarjetas de Alerta
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                itemCount: listaDeAvisos.length,
                itemBuilder: (context, index) {
                  final aviso = listaDeAvisos[index];
                  
                  return Card(
                    color: const Color(0xFF1E1E1E),
                    margin: const EdgeInsets.only(bottom: 14), // 🛠️ Corregido a EdgeInsets.only
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Color(0xFFE65100), width: 1.2),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: Color(0xFFE65100), size: 28),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  aviso.titulo.toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            aviso.descripcion,
                            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4), // 🛠️ Corregido a Colors.white70
                          ),
                          const SizedBox(height: 14),
                          const Divider(color: Colors.white10, height: 1),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Emisión: ${aviso.fechaEmision}',
                                style: const TextStyle(color: Colors.white38, fontSize: 11),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0x26E65100), // 🛠️ Corregido para limpiar el warning de withOpacity
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Validez: ${aviso.fechaVencimiento}',
                                  style: const TextStyle(color: Color(0xFFFFB74D), fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}