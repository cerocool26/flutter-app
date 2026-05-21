import 'package:socket_io_client/socket_io_client.dart' as io;

import '../config/api_config.dart';
import '../models/message.dart';

/// Wrapper sobre socket_io_client para el namespace /chat del backend.
/// El handshake envía el JWT vía `auth: { token: ... }`.
class ChatService {
  final String token;
  io.Socket? _socket;

  ChatService({required this.token});

  bool get isConnected => _socket?.connected ?? false;

  void connect({
    required void Function(List<ChatMessage> history) onHistory,
    required void Function(ChatMessage message) onMessage,
    required void Function(String reason) onDisconnect,
    required void Function(String error) onError,
    required void Function() onConnect,
  }) {
    final url = '${ApiConfig.socketUrl}${ApiConfig.chatNamespace}';
    _socket = io.io(
      url,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket!
      ..onConnect((_) => onConnect())
      ..onConnectError((e) => onError('connect_error: $e'))
      ..onError((e) => onError('error: $e'))
      ..onDisconnect((reason) => onDisconnect(reason?.toString() ?? 'desconocido'))
      ..on('message:history', (data) {
        if (data is List) {
          final msgs = data
              .whereType<Map>()
              .map((m) => ChatMessage.fromJson(Map<String, dynamic>.from(m)))
              .toList();
          onHistory(msgs);
        }
      })
      ..on('message:new', (data) {
        if (data is Map) {
          onMessage(ChatMessage.fromJson(Map<String, dynamic>.from(data)));
        }
      });

    _socket!.connect();
  }

  void send(String text) {
    final s = _socket;
    if (s == null || !s.connected) return;
    s.emitWithAck('message:send', {'text': text}, ack: (_) {});
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
