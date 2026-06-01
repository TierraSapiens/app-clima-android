import 'package:flutter/material.dart';
import 'package:app_clima_01/config/app_theme.dart';
import 'package:app_clima_01/views/info/pantalla_acerca_de.dart';

class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Podés usar un número fijo en píxeles (ej: 280) o un porcentaje de la pantalla.
      width: MediaQuery.of(context).size.width * 0.50, // 👈 Esto significa el 50% del ancho del celular
      child: Container(
        color: AppTheme.backgroundGradientBottom,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppTheme.cardSurface),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_queue,
                    color: AppTheme.accentPrimary,
                    size: 40, //Tamaño de nube principal
                  ),
                  SizedBox(height: 10),
                  Text(
                    'APP CLIMA',
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
              leading: const Icon(
                Icons.star_border,
                color: AppTheme.accentPrimary,
              ),
              title: const Text(
                'Favoritos',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(
                Icons.settings_outlined,
                color: Colors.white70,
              ),
              title: const Text(
                'Configuración',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.white70),
              title: const Text(
                'Acerca de',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                // 1. Primero cerramos el menú lateral (Drawer)
                Navigator.pop(context); 
                
                // 2. Segundo navegamos a la nueva pantalla escalable
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