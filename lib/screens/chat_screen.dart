import 'package:flutter/material.dart';
import '../models/character.dart';
import '../models/chat_message.dart';
import '../services/chat_storage_service.dart';
import '../services/chat_api_service.dart';
import 'package:uuid/uuid.dart';
import '../services/user_service.dart';

class ChatScreen extends StatefulWidget {
  final Character character;
  final String? initialQuestion;
  final String? sessionId;
  final bool saveHistory;
  final bool autoSendInitialQuestion;

  const ChatScreen({
    Key? key,
    required this.character,
    this.initialQuestion,
    this.sessionId,
    this.saveHistory = true,
    this.autoSendInitialQuestion = false,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late ChatStorageService _chatStorage;
  final ChatApiService _chatApi = ChatApiService();
  final ScrollController _scrollController = ScrollController();
  final UserService _userService = UserService();
  List<ChatMessage> _messages = [];
  final _uuid = const Uuid();
  bool _isLoading = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeChat();
    if (widget.autoSendInitialQuestion && widget.initialQuestion != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        
        while (_currentUserId == null) {
          if (!mounted) return;
          await Future.delayed(const Duration(milliseconds: 100));
        }

        if (!mounted) return;
        final text = widget.initialQuestion!;
        
        final userMessage = ChatMessage(
          id: _uuid.v4(),
          characterId: widget.character.id,
          content: text,
          isUser: true,
          timestamp: DateTime.now(),
        );

        if (!mounted) return;
        setState(() {
          _messages.add(userMessage);
          _isLoading = true;
        });
        
        try {
          final response = await _chatApi.sendMessage(text);
          if (!mounted) return;

          final aiMessage = ChatMessage(
            id: _uuid.v4(),
            characterId: widget.character.id,
            content: response,
            isUser: false,
            timestamp: DateTime.now(),
          );

          if (widget.saveHistory && mounted) {
            await _chatStorage.saveMessage(userMessage);
            await _chatStorage.saveMessage(aiMessage);
          }

          if (!mounted) return;
          setState(() {
            _messages.add(aiMessage);
            _isLoading = false;
          });
          _scrollToBottom();
        } catch (e) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send message: $e')),
          );
        }
      });
    }
  }

  Future<void> _initializeChat() async {
    try {
      _currentUserId = await _userService.getCurrentUserId();
      _chatStorage = ChatStorageService(userId: _currentUserId!);
      await _loadMessages();
    } catch (e) {
      print('Error initializing chat: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Initial chat failed')),
      );
    }
  }

  Future<void> _loadMessages() async {
    if (_currentUserId == null) return;
    
    try {
      final messages = await _chatStorage.getMessages(widget.character.id);
      setState(() {
        _messages = messages;
      });
      _scrollToBottom();
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_currentUserId == null) return;
    
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    // 创建用户消息
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      characterId: widget.character.id,
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      // 发送消息并获取回复
      final response = await _chatApi.sendMessage(text);

      // 创建AI回复消息
      final aiMessage = ChatMessage(
        id: _uuid.v4(),
        characterId: widget.character.id,
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      // 如果需要保存历史记录
      if (widget.saveHistory) {
        await _chatStorage.saveMessage(userMessage);
        await _chatStorage.saveMessage(aiMessage);
      }

      setState(() {
        _messages.add(aiMessage);
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(widget.character.avatarPath),
              radius: 20,
            ),
            const SizedBox(width: 8),
            Text(widget.character.nickname),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _MessageBubble(
                  message: message,
                  character: widget.character,
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -1),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Character character;

  const _MessageBubble({
    required this.message,
    required this.character,
  });

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(time.year, time.month, time.day);

    String timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    
    if (messageDate == today) {
      return timeStr;
    } else if (messageDate == yesterday) {
      return 'Yesterday $timeStr';
    } else {
      return '${time.month}/${time.day} $timeStr';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            _formatTime(message.timestamp),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isUser) ...[
              CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage(character.avatarPath),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: message.isUser
                      ? Theme.of(context).primaryColor
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  message.content,
                  style: TextStyle(
                    color: message.isUser ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
            if (message.isUser) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
} 