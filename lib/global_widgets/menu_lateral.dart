import 'package:flutter/material.dart';
import 'package:app_clima_01/views/info/pantalla_acerca_de.dart'; // 👈 ¡Ahora sí se usa!
import 'package:app_clima_01/views/favoritos/pantalla_favoritos.dart';

class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.65, // Un ancho cómodo para el menú
      child: Container(
        color: const Color(0xFF121212), // Fondo oscuro que combina con tu app
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFE65100)), // Tu naranja del SMN
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_queue, color: Colors.white, size: 40),
                  SizedBox(height: 10),
                  Text(
                    'ClimApp',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            
            // ⭐ Botón Favoritos
            ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: const Text('Favoritos', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PantallaFavoritos()),
                );
              },
            ),

            // ℹ️ Botón Acerca de (Usa el import y quita la advertencia)
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.white70),
              title: const Text('Acerca de', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PantallaAcercaDe()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}