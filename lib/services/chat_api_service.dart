import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatApiService {
  static const String API_KEY = "ZKLPfexh3NtNGPMPDlxYaLRF";
  static const String SECRET_KEY = "f8CJzGeCtL8rn7Ky71bLXa71lvPyr5Bz";
  
  // 获取access token
  Future<String> getAccessToken() async {
    final url = Uri.parse('https://aip.baidubce.com/oauth/2.0/token');
    try {
      final response = await http.post(
        url,
        body: {
          'grant_type': 'client_credentials',
          'client_id': API_KEY,
          'client_secret': SECRET_KEY,
        },
      );

      //print('Access Token Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['access_token'];
      } else {
        throw Exception('Failed to get access token: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error getting access token: $e');
      rethrow;
    }
  }

  // 发送聊天消息
  Future<String> sendMessage(String message) async {
    try {
      final accessToken = await getAccessToken();
      final url = Uri.parse(
          'https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/completions_pro?access_token=$accessToken');

      final enhancedMessage = '''
Please respond in English only. Act as the character and maintain their personality while responding.

User message: $message
''';

      final payload = {
        'messages': [
          {
            'role': 'user',
            'content': enhancedMessage,
          }
        ],
        'temperature': 0.95,
        'top_p': 0.8,
        'penalty_score': 1,
        'stream': false,
        'user_id': 'user',
      };

      //print('Request payload: ${json.encode(payload)}');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      //print('Chat Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['result'] ?? 'No response from API';
      } else {
        throw Exception('Failed to send message: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }
} 