import 'package:equatable/equatable.dart';

const _unset = Object();

class User extends Equatable {
  final String email;
  final String nickname;
  final String? school;
  final String? profileImageUrl;

  const User({
    required this.email,
    required this.nickname,
    this.school,
    this.profileImageUrl,
  });

  User copyWith({
    String? email,
    String? nickname,
    Object? school = _unset,
    Object? profileImageUrl = _unset,
  }) {
    return User(
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      school: school == _unset ? this.school : school as String?,
      profileImageUrl: profileImageUrl == _unset
          ? this.profileImageUrl
          : profileImageUrl as String?,
    );
  }

  @override
  List<Object?> get props => [email, nickname, school, profileImageUrl];
}
