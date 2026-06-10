import 'package:flutter/material.dart';
import 'package:app_clima_01/views/info/pantalla_acerca_de.dart';
import 'package:app_clima_01/views/favoritos/pantalla_favoritos.dart';
import 'package:app_clima_01/views/configuracion/pantalla_configuracion.dart';

class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.50,
      child: Material(
        // <--- AHORA ES UN MATERIAL
        color: const Color.fromARGB(255, 2, 3, 65),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color.fromARGB(255, 3, 3, 37)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_queue, color: Colors.white, size: 40),
                  SizedBox(height: 10),
                  Text(
                    'ClimApp',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: const Text(
                'Favoritos',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PantallaFavoritos(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white70),
              title: const Text(
                'Configuración',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context); // Cierra el menú lateral
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PantallaConfiguracion(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.white70),
              title: const Text(
                'Acerca de',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PantallaAcercaDe(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
