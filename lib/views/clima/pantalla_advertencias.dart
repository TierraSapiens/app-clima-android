import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'advertencias_controller.dart';

class PantallaAdvertencias extends ConsumerWidget {
  const PantallaAdvertencias({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final advertenciasAsync = ref.watch(advertenciasProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Advertencias',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFE65100),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(advertenciasProvider);
            },
          ),
        ],
      ),
      body: advertenciasAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (err, stack) => Center(
          child: Text(
            '❌ Error al conectar con el SMN: $err',
            style: const TextStyle(color: Colors.red),
          ),
        ),
        data: (listaAdvertencias) {
          // CLON DE TU ESTÍTICA SI NO HAY ADVERTENCIAS
          if (listaAdvertencias.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: Color(0xFF35c795),
                      size: 90,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Sin advertencias vigentes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No se esperan fenómenos meteorológicos que impliquen riesgos (Niebla, polvo o humo).',
                      style: TextStyle(color: Colors.white38, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // SI HAY ADVERTENCIAS, SE LISTAN TEXTUALMENTE
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listaAdvertencias.length,
            itemBuilder: (context, index) {
              final adv = listaAdvertencias[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.amber,
                    size: 28,
                  ),
                  title: Text(
                    adv.titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      adv.descripcion,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
