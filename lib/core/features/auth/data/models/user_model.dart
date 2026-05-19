import 'package:bumditbul_mobile/core/features/auth/domain/entities/user_entity.dart';

class UserModel extends User {
  const UserModel({
    required super.email,
    required super.nickname,
    super.school,
    super.profileImageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        email: json['email'] as String? ?? '',
        nickname: json['nickname'] as String? ?? '',
        school: json['school'] as String?,
        profileImageUrl: json['profileImageUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        'nickname': nickname,
        if (school != null) 'school': school,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      };

  factory UserModel.fromEntity(User user) => UserModel(
        email: user.email,
        nickname: user.nickname,
        school: user.school,
        profileImageUrl: user.profileImageUrl,
      );
}
