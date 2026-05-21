class ChatMessage {
  final String id;
  final String userId;
  final String role;
  final String text;
  final DateTime at;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.role,
    required this.text,
    required this.at,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: json['userId']?.toString() ?? '',
      role: json['role']?.toString() ?? 'client',
      text: json['text']?.toString() ?? '',
      at: DateTime.tryParse(json['at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
