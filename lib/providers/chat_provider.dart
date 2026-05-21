import 'package:flutter/foundation.dart';

import '../models/message.dart';
import '../services/chat_service.dart';

enum ChatStatus { idle, connecting, connected, disconnected, error }

class ChatProvider extends ChangeNotifier {
  final String? token;
  ChatService? _service;

  final List<ChatMessage> _messages = [];
  ChatStatus _status = ChatStatus.idle;
  String? _error;

  ChatProvider({required this.token});

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  ChatStatus get status => _status;
  String? get error => _error;
  bool get isConnected => _status == ChatStatus.connected;

  void connect() {
    if (token == null) {
      _status = ChatStatus.error;
      _error = 'Sin sesión activa';
      notifyListeners();
      return;
    }
    if (_service != null && isConnected) return;

    _status = ChatStatus.connecting;
    _error = null;
    notifyListeners();

    _service = ChatService(token: token!);
    _service!.connect(
      onConnect: () {
        _status = ChatStatus.connected;
        _error = null;
        notifyListeners();
      },
      onDisconnect: (reason) {
        _status = ChatStatus.disconnected;
        notifyListeners();
      },
      onError: (err) {
        _status = ChatStatus.error;
        _error = err;
        notifyListeners();
      },
      onHistory: (history) {
        _messages
          ..clear()
          ..addAll(history);
        notifyListeners();
      },
      onMessage: (msg) {
        _messages.add(msg);
        notifyListeners();
      },
    );
  }

  void send(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _service?.send(trimmed);
  }

  void disconnectSocket() {
    _service?.disconnect();
    _service = null;
    _status = ChatStatus.disconnected;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnectSocket();
    super.dispose();
  }
}
