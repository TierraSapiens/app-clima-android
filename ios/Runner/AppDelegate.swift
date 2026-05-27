import Flutter
import UIKit
import GoogleMaps // <-- 1. Agregamos la librería de mapas aquí abajo

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // <-- 2. Registramos la API Key justo acá, antes del return
    GMSServices.provideAPIKey("ACÁ_VA_TU_API_KEY_DE_GOOGLE_MAPS")
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}