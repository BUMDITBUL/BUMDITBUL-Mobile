import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserPrefs {
  static const _emailKey = 'pref_email';
  static const _nicknameKey = 'pref_nickname';
  static const _schoolKey = 'pref_school';
  static const _examDateKey = 'pref_exam_date';

  static const _options = AndroidOptions(encryptedSharedPreferences: true);
  final FlutterSecureStorage _storage;

  UserPrefs() : _storage = const FlutterSecureStorage(aOptions: _options);

  Future<void> saveProfile({
    required String email,
    required String nickname,
    String? school,
  }) async {
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _nicknameKey, value: nickname);
    if (school != null) {
      await _storage.write(key: _schoolKey, value: school);
    } else {
      await _storage.delete(key: _schoolKey);
    }
  }

  Future<({String email, String nickname, String? school})?> loadProfile() async {
    final email = await _storage.read(key: _emailKey);
    final nickname = await _storage.read(key: _nicknameKey);
    if (email == null || nickname == null) return null;
    final school = await _storage.read(key: _schoolKey);
    return (email: email, nickname: nickname, school: school);
  }

  Future<void> updateNicknameAndSchool({
    required String nickname,
    String? school,
  }) async {
    await _storage.write(key: _nicknameKey, value: nickname);
    if (school != null) {
      await _storage.write(key: _schoolKey, value: school);
    } else {
      await _storage.delete(key: _schoolKey);
    }
  }

  Future<void> saveExamDate(DateTime date) async {
    await _storage.write(key: _examDateKey, value: date.toIso8601String());
  }

  Future<DateTime?> loadExamDate() async {
    final value = await _storage.read(key: _examDateKey);
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  Future<void> clearExamDate() async {
    await _storage.delete(key: _examDateKey);
  }

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _emailKey),
      _storage.delete(key: _nicknameKey),
      _storage.delete(key: _schoolKey),
      _storage.delete(key: _examDateKey),
    ]);
  }
}
