import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PantallaAlertas extends StatefulWidget {
  const PantallaAlertas({super.key});

  @override
  State<PantallaAlertas> createState() => _PantallaAlertasState();
}

class _PantallaAlertasState extends State<PantallaAlertas> {
  late final WebViewController _controller;
  bool _isLoading = true; // Para mostrar una carga prolija mientras descarga el mapa

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            // 1. Inyectamos el código para limpiar la interfaz del SMN
            _controller.runJavaScript('''
              (function() {
                var style = document.createElement('style');
                style.type = 'text/css';
                style.innerHTML = `
                  .jumbotron, .pane-jumbotron, 
                  .pane-smn-alertas-smn-alertas-menu, 
                  #launch, #updatedTime { display: none !important; }
                  
                  .main-container, .row, .container, .inside { 
                    width: 100% !important; 
                    max-width: 100% !important; 
                    padding: 0 !important; 
                    margin: 0 !important; 
                  }
                  #mapa { height: 100vh !important; min-height: 100vh !important; }
                `;
                document.head.appendChild(style);
              })();
            ''');
            
            // 2. Apagamos el indicador de carga
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('https://www.smn.gob.ar/alertas'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas Tempranas SMN'),
        // Podés usar el color de tu app_theme aquí si lo preferís
        backgroundColor: Colors.blueAccent, 
      ),
      body: Stack(
        children: [
          // El mapa web funcional
          WebViewWidget(controller: _controller),
          
          // Pantalla de carga mientras se procesa el mapa
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}