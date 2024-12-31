class Character {
  final String id;
  final String nickname;
  final String role;
  final String description;
  final String avatarPath;
  final List<String> skills;
  final String personality;
  final String background;
  final List<String> equipment;

  Character({
    required this.id,
    required this.nickname,
    required this.role,
    required this.description,
    required this.avatarPath,
    required this.skills,
    required this.personality,
    required this.background,
    required this.equipment,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] ?? '',
      nickname: json['nickname'] ?? '',
      role: json['role'] ?? '',
      description: json['description'] ?? '',
      avatarPath: json['avatarPath'] ?? '',
      skills: (json['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      personality: json['personality'] ?? '',
      background: json['background'] ?? '',
      equipment: (json['equipment'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'role': role,
      'description': description,
      'avatarPath': avatarPath,
      'skills': skills,
      'personality': personality,
      'background': background,
      'equipment': equipment,
    };
  }
} 