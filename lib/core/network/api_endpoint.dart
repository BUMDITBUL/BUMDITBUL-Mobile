import 'package:bumditbul_mobile/core/config/app_env.dart';

class ApiEndpoint {
  static const baseUrl = AppEnv.baseUrl;

  /// ai
  static const aiRebalance = '/ai/schedule/rebalance';
  static const aiAnalyze = '/ai/schedule/analyze';

  /// auth
  static const withdraw = '/auth/withdraw';
  static const refreshToken = '/auth/token/refresh';
  static const signUp = '/auth/signup';
  static const logout = '/auth/logout';
  static const login = '/auth/login';
  static const emailVerify = '/auth/email/verify';
  static const emailSend = '/auth/email/send';
  static const googleOAuth = '/auth/oauth/google';

  /// schedule
  static const scheduleStatus = '/schedule/status';
  static const scheduleCount = '/schedule/regen-count';
  static const scheduleGenerate = '/schedule/generate';
  static const scheduleDaily = '/schedule/daily';
  static const scheduleCalendar = '/schedule/calendar';
  static String scheduleDone(String id) => '/schedule/$id/done';

  /// subject
  static const subjects = '/subjects';

  /// user
  static const profile = '/users/me';
  static const examDate = '/users/me/exam-date';
  static const profileImage = '/users/me/profile-image';
}