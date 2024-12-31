import 'package:flutter/material.dart';
import '../models/character.dart';
import '../models/chat_message.dart';
import '../services/chat_storage_service.dart';
import '../services/user_service.dart';
import 'chat_screen.dart';
import 'dart:convert';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  List<ChatHistoryItem> _chatHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    try {
      final userId = await UserService().getCurrentUserId();
      final chatStorage = ChatStorageService(userId: userId);
      
      final String jsonString = await DefaultAssetBundle.of(context)
          .loadString('assets/data/characters.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final characters = (jsonData['characters'] as List)
          .map((json) => Character.fromJson(json))
          .toList();

      final List<ChatHistoryItem> history = [];

      for (var character in characters) {
        final messages = await chatStorage.getMessages(character.id);
        final lastMessage = messages.isNotEmpty ? messages.last : null;
        
        history.add(ChatHistoryItem(
          character: character,
          lastMessage: lastMessage,
        ));
      }

      history.sort((a, b) {
        if (a.lastMessage == null && b.lastMessage == null) return 0;
        if (a.lastMessage == null) return 1;
        if (b.lastMessage == null) return -1;
        return b.lastMessage!.timestamp.compareTo(a.lastMessage!.timestamp);
      });

      setState(() {
        _chatHistory = history;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading chat history: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.year == time.year) {
      return '${time.month}/${time.day}';
    } else {
      return '${time.year}/${time.month}/${time.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat History'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _chatHistory.length,
        itemBuilder: (context, index) {
          final item = _chatHistory[index];
          final defaultMessage = "Hello! I am ${item.character.nickname}";
          
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(character: item.character),
                  ),
                ).then((_) => _loadChatHistory());
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 角色头像
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: AssetImage(item.character.avatarPath),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 聊天信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.character.nickname,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _formatTime(item.lastMessage?.timestamp),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.character.role,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.lastMessage?.content ?? defaultMessage,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ChatHistoryItem {
  final Character character;
  final ChatMessage? lastMessage;

  ChatHistoryItem({
    required this.character,
    this.lastMessage,
  });
} 