import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/message.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().connect();
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onSend() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    context.read<ChatProvider>().send(text);
    _textCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final me = context.watch<AuthProvider>().user;

    if (chat.messages.isNotEmpty) _scrollToBottom();

    return Column(
      children: [
        _StatusBar(status: chat.status, error: chat.error),
        Expanded(
          child: chat.messages.isEmpty
              ? Center(
                  child: Text(
                    chat.isConnected
                        ? 'Sin mensajes aún. ¡Saluda!'
                        : 'Conectando al chat...',
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(12),
                  itemCount: chat.messages.length,
                  itemBuilder: (_, i) {
                    final m = chat.messages[i];
                    final mine = me != null && m.userId == me.id;
                    return _Bubble(message: m, mine: mine);
                  },
                ),
        ),
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textCtrl,
                    enabled: chat.isConnected,
                    onSubmitted: (_) => _onSend(),
                    decoration: InputDecoration(
                      hintText: chat.isConnected ? 'Escribe un mensaje...' : 'Esperando conexión',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton.filled(
                  onPressed: chat.isConnected ? _onSend : null,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBar extends StatelessWidget {
  final ChatStatus status;
  final String? error;
  const _StatusBar({required this.status, this.error});

  @override
  Widget build(BuildContext context) {
    Color bg;
    String label;
    switch (status) {
      case ChatStatus.connected:
        bg = Colors.green.shade100;
        label = 'Conectado al chat';
        break;
      case ChatStatus.connecting:
        bg = Colors.amber.shade100;
        label = 'Conectando...';
        break;
      case ChatStatus.error:
        bg = Colors.red.shade100;
        label = 'Error: ${error ?? "desconocido"}';
        break;
      case ChatStatus.disconnected:
        bg = Colors.grey.shade300;
        label = 'Desconectado';
        break;
      case ChatStatus.idle:
        bg = Colors.grey.shade200;
        label = 'Inactivo';
    }
    return Container(
      width: double.infinity,
      color: bg,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage message;
  final bool mine;
  const _Bubble({required this.message, required this.mine});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('HH:mm');
    final align = mine ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = mine
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.surfaceContainerHighest;
    final textColor = mine ? Colors.white : Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: align,
        children: [
          if (!mine)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 2),
              child: Text(
                '${message.role} · ${message.userId.substring(0, message.userId.length.clamp(0, 8))}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ),
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(mine ? 16 : 4),
                bottomRight: Radius.circular(mine ? 4 : 16),
              ),
            ),
            child: Text(message.text, style: TextStyle(color: textColor)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Text(fmt.format(message.at.toLocal()),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
