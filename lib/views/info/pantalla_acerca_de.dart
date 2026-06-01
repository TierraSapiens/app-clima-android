import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_clima_01/config/app_theme.dart';

class PantallaAcercaDe extends StatelessWidget {
  const PantallaAcercaDe({super.key});

  /// Método para abrir el correo o enlaces externos de forma segura
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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFE65100),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // 🌤️ Logo de la App
            const Icon(
              Icons.cloud_queue,
              size: 70,
              color: AppTheme.accentPrimary,
            ),
            const SizedBox(height: 12),
            const Text(
              'METEOMARTI v1.0.0',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            const SizedBox(height: 6),
            const Text(
              'Datos oficiales en tiempo real del SMN.',
              style: TextStyle(color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 20),
            const Divider(color: Colors.white10),
            const SizedBox(height: 12),

            // 🔥 NUEVA SECCIÓN: ESTADO DEL PROYECTO
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ESTADO DEL PROYECTO',
                style: TextStyle(color: Color.fromARGB(255, 255, 249, 232), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
            ),
            const SizedBox(height: 8),
            
            // Tarjeta de aviso de Desarrollo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.2), width: 1),
              ),
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
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Esta app se encuentra en fase de pruebas. Si encontrás algún error, tenés sugerencias o querés realizar cualquier tipo de consulta, tu mensaje es más que bienvenido para seguir mejorando.',
                          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 📬 SECCIÓN DE CONTACTO
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'CONTACTO',
                style: TextStyle(color: Color.fromARGB(255, 248, 227, 216), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
            ),
            const SizedBox(height: 8),

            Card(
              color: const Color(0xFF1E1E1E),
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  // Opción de Correo Electrónico
                  ListTile(
                    leading: const Icon(Icons.email_outlined, color: Color(0xFF35c795)),
                    title: const Text('Enviar Consulta / Sugerencia', style: TextStyle(color: Colors.white, fontSize: 14)),
                    subtitle: const Text('trinidadmdp@gmail.com', style: TextStyle(color: Colors.white54, fontSize: 13)), // 👈 Cambiá por tu mail
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
                    onTap: () => _abrirEnlace('mailto:tu-correo@email.com'), // 👈 Mantener el mailto:
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  
                  // Opción de GitHub (Podés borrar este ListTile entero si no lo usás)
                  ListTile(
                    leading: const Icon(Icons.code_rounded, color: Colors.blueAccent),
                    title: const Text('Código Fuente / GitHub', style: TextStyle(color: Colors.white, fontSize: 14)),
                    subtitle: const Text('https://github.com/TierraSapiens/app-clima-android', style: TextStyle(color: Colors.white54, fontSize: 13)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
                    onTap: () => _abrirEnlace('https://github.com/tu-usuario'),
                  ),
                ],
              ),
            ),

            const Spacer(),
            
            // 🛡️ Pie de página
            const Text(
              'Esta aplicación es de uso informativo y no comercial.',
              style: TextStyle(color: Colors.white38, fontSize: 11),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Text(
              '© 2026 MeteoMarti. Todos los derechos reservados.',
              style: TextStyle(color: Colors.white24, fontSize: 11),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}