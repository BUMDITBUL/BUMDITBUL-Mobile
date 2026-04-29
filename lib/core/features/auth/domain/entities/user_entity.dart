import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String nickname;
  final String? school;
  final String? token;

  const User({
    required this.id,
    required this.email,
    required this.nickname,
    this.school,
    this.token,
  });

  @override
  List<Object?> get props => [id, email, nickname, school, token];

  User copyWith({
    String? id,
    String? email,
    String? nickname,
    String? school,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      school: school ?? this.school,
      token: token ?? this.token,
    );
  }
}
