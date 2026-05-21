import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Configuración central de URLs del backend.
/// - Android emulator usa 10.0.2.2 para alcanzar localhost del host.
/// - iOS simulator y web pueden usar localhost.
/// - Para un dispositivo físico, cambia [_lanHost] a la IP de tu PC en la LAN.
class ApiConfig {
  ApiConfig._();

  static const String _port = '3000';
  static const String _lanHost = '192.168.1.100'; // Cambiar si usas dispositivo físico

  static String get host {
    if (kIsWeb) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2';
    if (Platform.isIOS) return 'localhost';
    return 'localhost';
  }

  /// Base HTTP — para auth y products
  static String get baseUrl => 'http://$host:$_port';

  /// Base Socket.IO — namespace /chat
  static String get socketUrl => 'http://$host:$_port';
  static const String chatNamespace = '/chat';

  /// Útil cuando se prueba en dispositivo físico
  static String get lanBaseUrl => 'http://$_lanHost:$_port';
}
