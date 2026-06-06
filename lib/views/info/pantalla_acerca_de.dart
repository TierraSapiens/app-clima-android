import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_clima_01/config/app_theme.dart';

class PantallaAcercaDe extends StatelessWidget {
  const PantallaAcercaDe({super.key});
  Future<void> _abrirEnlace(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("No se pudo abrir el enlace: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Acerca de',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFFE65100),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // 👈 CORREGIDO: spaceBetween en lugar de between
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE65100).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.cloud_queue,
                            size: 64,
                            color: AppTheme.accentPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'ClimApp v1.0.0',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Datos oficiales en tiempo real del SMN.',
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 24),
                        const Divider(color: Colors.white10, height: 1),
                        const SizedBox(height: 24),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'ESTADO DEL PROYECTO',
                            style: TextStyle(color: Color(0xFFFFE9E2), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                          ),
                        ),
                        const SizedBox(height: 10),
                        
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  left: BorderSide(color: Colors.amber, width: 4),
                                ),
                              ),
                              padding: const EdgeInsets.all(16.0),
                              child: const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.construction_rounded, color: Colors.amber, size: 22),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Aplicación en Desarrollo Activo',
                                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          'Esta app se encuentra en fase de pruebas. Si encontrás algún error, tenés sugerencias o querés realizar cualquier tipo de consulta, tu mensaje es más que bienvenido para seguir mejorando.',
                                          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'CONTACTO',
                            style: TextStyle(color: Color(0xFFFFE9E2), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                          ),
                        ),
                        const SizedBox(height: 10),

                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                leading: const Icon(Icons.email_outlined, color: Color(0xFF35c795)),
                                title: const Text('Enviar Consulta / Sugerencia', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                                subtitle: const Text('trinidadmdp@gmail.com', style: TextStyle(color: Colors.white54, fontSize: 13)), 
                                trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 12),
                                onTap: () => _abrirEnlace('mailto:trinidadmdp@gmail.com'),
                              ),
                              const Divider(color: Colors.white10, height: 1, indent: 16, endIndent: 16),
                              
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                leading: const Icon(Icons.code_rounded, color: Colors.blueAccent),
                                title: const Text('Código Fuente / GitHub', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                                subtitle: const Text('TierraSapiens/app-clima-android', style: TextStyle(color: Colors.white54, fontSize: 13)),
                                trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 12),
                                onTap: () => _abrirEnlace('https://github.com/TierraSapiens/app-clima-android'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Padding(
                      padding: EdgeInsets.only(top: 32.0),
                      child: Column(
                        children: [
                          Text(
                            'Esta aplicación es de uso informativo y no comercial.',
                            style: TextStyle(color: Colors.white38, fontSize: 11),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4),
                          Text(
                            '© 2026 ClimApp. Todos los derechos reservados.',
                            style: TextStyle(color: Colors.white24, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}