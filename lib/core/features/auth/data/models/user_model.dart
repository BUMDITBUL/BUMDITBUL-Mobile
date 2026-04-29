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
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      nickname: json['nickname'] as String,
      school: json['school'] as String?,
      token: json['token'] as String?,
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
