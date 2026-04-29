import 'package:bumditbul_mobile/core/features/auth/domain/entities/user_entity.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.nickname,
    super.school,
    super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Defensive parsing with proper type checking
    final id = json['id'];
    final email = json['email'];
    final nickname = json['nickname'];

    if (id == null || id is! String || id.isEmpty) {
      throw FormatException('Invalid or missing id in UserModel.fromJson');
    }
    if (email == null || email is! String || email.isEmpty) {
      throw FormatException('Invalid or missing email in UserModel.fromJson');
    }
    if (nickname == null || nickname is! String || nickname.isEmpty) {
      throw FormatException('Invalid or missing nickname in UserModel.fromJson');
    }

    return UserModel(
      id: id,
      email: email,
      nickname: nickname,
      school: json['school']?.toString(),
      token: json['token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nickname': nickname,
      'school': school,
      'token': token,
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      nickname: user.nickname,
      school: user.school,
      token: user.token,
    );
  }
}
