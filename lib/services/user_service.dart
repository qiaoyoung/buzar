import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class UserService {
  static const String _userIdKey = 'current_user_id';
  
  // 获取当前用户ID，如果不存在则创建新的
  Future<String> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString(_userIdKey);
    
    if (userId == null) {
      userId = const Uuid().v4(); // 生成新的用户ID
      await prefs.setString(_userIdKey, userId);
    }
    
    return userId;
  }
} 