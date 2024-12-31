import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';

class ChatStorageService {
  static const String _messagePrefix = 'chat_messages_';
  final String userId;
  
  ChatStorageService({required this.userId});
  
  // 生成存储key
  String _generateKey(String characterId) {
    return '${_messagePrefix}${userId}_$characterId';
  }
  
  // 保存消息
  Future<void> saveMessage(ChatMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _generateKey(message.characterId);
    
    // 获取现有消息
    List<ChatMessage> messages = await getMessages(message.characterId);
    messages.add(message);
    
    // 将消息列表转换为JSON字符串
    final messagesJson = messages.map((m) => m.toJson()).toList();
    await prefs.setString(key, json.encode(messagesJson));
  }
  
  // 获取与特定角色的所有消息
  Future<List<ChatMessage>> getMessages(String characterId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _generateKey(characterId);
    
    final messagesJson = prefs.getString(key);
    if (messagesJson == null) return [];
    
    final List<dynamic> decoded = json.decode(messagesJson);
    return decoded.map((json) => ChatMessage.fromJson(json)).toList();
  }
  
  // 清除与特定角色的所有消息
  Future<void> clearMessages(String characterId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _generateKey(characterId);
    await prefs.remove(key);
  }
  
  // 清除当前用户的所有聊天记录
  Future<void> clearAllMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    
    for (final key in allKeys) {
      if (key.startsWith('${_messagePrefix}${userId}_')) {
        await prefs.remove(key);
      }
    }
  }
} 