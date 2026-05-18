import 'package:dio/dio.dart';

class NeisSchool {
  final String name;
  final String officeCode;
  final String schoolCode;
  final String location;
  final String schoolType;
  final int? grade;
  final DateTime? nearestExamDate;

  const NeisSchool({
    required this.name,
    required this.officeCode,
    required this.schoolCode,
    required this.location,
    required this.schoolType,
    this.grade,
    this.nearestExamDate,
  });

  NeisSchool copyWith({int? grade, DateTime? nearestExamDate}) => NeisSchool(
        name: name,
        officeCode: officeCode,
        schoolCode: schoolCode,
        location: location,
        schoolType: schoolType,
        grade: grade ?? this.grade,
        nearestExamDate: nearestExamDate ?? this.nearestExamDate,
      );
}

class NeisService {
  static const _apiKey = 'cd4585c0fedb417191a27cced8ab588f';
  static const _baseUrl = 'https://open.neis.go.kr/hub';

  static final _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  static Future<List<NeisSchool>> searchSchools(String query) async {
    if (query.trim().length < 2) return [];
    try {
      final res = await _dio.get('/schoolInfo', queryParameters: {
        'KEY': _apiKey,
        'Type': 'json',
        'pIndex': 1,
        'pSize': 20,
        'SCHUL_NM': query.trim(),
      });

      final schoolInfo = res.data['schoolInfo'] as List<dynamic>?;
      if (schoolInfo == null || schoolInfo.length < 2) return [];

      final rows = schoolInfo[1]['row'] as List<dynamic>? ?? [];
      return rows.map((r) {
        return NeisSchool(
          name: r['SCHUL_NM'] as String,
          officeCode: r['ATPT_OFCDC_SC_CODE'] as String,
          schoolCode: r['SD_SCHUL_CODE'] as String,
          location: r['LCTN_SC_NM'] as String? ?? '',
          schoolType: r['SCHUL_KND_SC_NM'] as String? ?? '',
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<DateTime?> getNearestExamDate(
    String officeCode,
    String schoolCode, {
    int? grade,
  }) async {
    final now = DateTime.now();
    final from =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final to = '${now.year}1231';

    const gradeField = {
      1: 'ONE_GRADE_EVENT_YN',
      2: 'TW_GRADE_EVENT_YN',
      3: 'THREE_GRADE_EVENT_YN',
    };

    try {
      final res = await _dio.get('/SchoolSchedule', queryParameters: {
        'KEY': _apiKey,
        'Type': 'json',
        'ATPT_OFCDC_SC_CODE': officeCode,
        'SD_SCHUL_CODE': schoolCode,
        'AA_FROM_YMD': from,
        'AA_TO_YMD': to,
      });

      final schedule = res.data['SchoolSchedule'] as List<dynamic>?;
      if (schedule == null || schedule.length < 2) return null;

      final rows = schedule[1]['row'] as List<dynamic>? ?? [];

      const examKeywords = ['시험', '고사', '평가', '수능'];
      final examDates = <DateTime>[];

      for (final row in rows) {
        final eventName = row['EVENT_NM'] as String? ?? '';
        final dateStr = row['AA_YMD'] as String? ?? '';

        final isExam = examKeywords.any((k) => eventName.contains(k));
        if (!isExam || dateStr.length != 8) continue;

        if (grade != null) {
          final field = gradeField[grade];
          if (field != null) {
            final applies = row[field] as String? ?? 'N';
            if (applies != 'Y') continue;
          }
        }

        final year = int.parse(dateStr.substring(0, 4));
        final month = int.parse(dateStr.substring(4, 6));
        final day = int.parse(dateStr.substring(6, 8));
        final date = DateTime(year, month, day);

        if (date.isAfter(now)) examDates.add(date);
      }

      if (examDates.isEmpty) return null;
      examDates.sort();
      return examDates.first;
    } catch (_) {
      return null;
    }
  }
}
