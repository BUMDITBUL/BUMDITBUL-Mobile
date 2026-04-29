import 'package:equatable/equatable.dart';

const _unset = Object();

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
    Object? school = _unset,
    Object? token = _unset,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      school: school == _unset ? this.school : school as String?,
      token: token == _unset ? this.token : token as String?,
    );
  }
}
