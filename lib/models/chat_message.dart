class ChatMessage {
  final String id;
  final String characterId;
  final String content;
  final bool isUser; // true表示用户发送的消息，false表示角色发送的消息
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.characterId,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      characterId: json['characterId'],
      content: json['content'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'characterId': characterId,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }
} 