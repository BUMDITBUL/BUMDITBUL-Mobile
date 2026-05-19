import 'package:bumditbul_mobile/core/features/auth/presentation/providers/auth_providers.dart';
import 'package:bumditbul_mobile/core/features/main/domain/entities/study_entities.dart';
import 'package:bumditbul_mobile/core/features/schedule/domain/entities/study_plan_entity.dart';
import 'package:bumditbul_mobile/core/features/schedule/presentation/providers/schedule_providers.dart';
import 'package:bumditbul_mobile/core/services/user_prefs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:bumditbul_mobile/core/features/schedule/presentation/providers/schedule_providers.dart'
    show
        subjectProvider,
        regenCountProvider,
        calendarProvider,
        dailyPlanProvider,
        examDateFromServerProvider,
        todayAchievementRealProvider;

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final displayMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});

class _ExamDateNotifier extends StateNotifier<DateTime?> {
  final UserPrefs _prefs;

  _ExamDateNotifier(this._prefs) : super(null) {
    _load();
  }

  Future<void> _load() async {
    final stored = await _prefs.loadExamDate();
    if (stored != null && mounted) state = stored;
  }

  Future<void> set(DateTime date) async {
    state = date;
    await _prefs.saveExamDate(date);
  }

  Future<void> clear() async {
    state = null;
    await _prefs.clearExamDate();
  }
}

final examDateNotifierProvider =
    StateNotifierProvider<_ExamDateNotifier, DateTime?>((ref) {
      return _ExamDateNotifier(ref.watch(userPrefsProvider));
    });

final examDateProvider = Provider<DateTime?>((ref) {
  final override = ref.watch(examDateNotifierProvider);
  if (override != null) return override;
  return ref.watch(examDateFromServerProvider);
});

void setExamDateOverride(WidgetRef ref, DateTime date) {
  ref.read(examDateNotifierProvider.notifier).set(date);
}

void clearExamDateOverride(WidgetRef ref) {
  ref.read(examDateNotifierProvider.notifier).clear();
}

class StudyState {
  final Map<String, List<StudySubject>> subjectsByDate;

  const StudyState({this.subjectsByDate = const {}});

  StudyState copyWith({Map<String, List<StudySubject>>? subjectsByDate}) =>
      StudyState(subjectsByDate: subjectsByDate ?? this.subjectsByDate);

  List<StudySubject> getSubjectsForDate(DateTime date) =>
      subjectsByDate[_dateKey(date)] ?? [];

  bool hasTasksOnDate(DateTime date) =>
      (subjectsByDate[_dateKey(date)] ?? []).isNotEmpty;

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

Map<String, List<StudySubject>> _plansToState(List<StudyPlan> plans) {
  final Map<String, Map<String, List<StudyPlan>>> byDateBySubject = {};

  for (final plan in plans) {
    byDateBySubject
        .putIfAbsent(plan.studyDate, () => {})
        .putIfAbsent(plan.subject, () => [])
        .add(plan);
  }

  return byDateBySubject.map((date, subjectMap) {
    final subjects = subjectMap.entries.map((e) {
      final subjectPlans = e.value;
      final difficulty = _apiToKorean(subjectPlans.first.difficulty);

      final tasks = subjectPlans.map((p) {
        final label = p.isReview
            ? '[복습] ${p.reviewMinutes}분'
            : 'p${p.startPage} ~ p${p.endPage}';
        return StudyTask(id: p.id, description: label, isCompleted: p.done);
      }).toList();

      return StudySubject(
        id: '${date}_${e.key}',
        name: e.key,
        difficulty: difficulty,
        tasks: tasks,
      );
    }).toList();

    return MapEntry(date, subjects);
  });
}

String _apiToKorean(String api) => switch (api.toUpperCase()) {
  'HIGH' => '상',
  'LOW' => '하',
  _ => '중',
};

class StudyNotifier extends StateNotifier<StudyState> {
  final Ref _ref;

  StudyNotifier(this._ref) : super(const StudyState());

  void syncFromPlans(List<StudyPlan> plans) {
    state = StudyState(subjectsByDate: _plansToState(plans));
  }

  Future<void> toggleTask(
    DateTime date,
    String subjectId,
    String taskId,
  ) async {
    final key = StudyState._dateKey(date);
    final subjects = List<StudySubject>.from(state.subjectsByDate[key] ?? []);
    final sIdx = subjects.indexWhere((s) => s.id == subjectId);
    if (sIdx == -1) return;

    final tasks = List<StudyTask>.from(subjects[sIdx].tasks);
    final tIdx = tasks.indexWhere((t) => t.id == taskId);
    if (tIdx == -1) return;
    final currentDone = tasks[tIdx].isCompleted;
    tasks[tIdx] = tasks[tIdx].copyWith(isCompleted: !currentDone);
    subjects[sIdx] = subjects[sIdx].copyWith(tasks: tasks);
    state = state.copyWith(
      subjectsByDate: Map.from(state.subjectsByDate)..[key] = subjects,
    );

    await _ref.read(dailyPlanProvider.notifier).toggle(taskId, currentDone);
  }

  void addTask(DateTime date, String subjectId, String description) {
    final key = StudyState._dateKey(date);
    final subjects = List<StudySubject>.from(state.subjectsByDate[key] ?? []);
    final sIdx = subjects.indexWhere((s) => s.id == subjectId);
    if (sIdx == -1) return;
    final tasks = List<StudyTask>.from(subjects[sIdx].tasks);
    tasks.add(
      StudyTask(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        description: description,
      ),
    );
    subjects[sIdx] = subjects[sIdx].copyWith(tasks: tasks);
    state = state.copyWith(
      subjectsByDate: Map.from(state.subjectsByDate)..[key] = subjects,
    );
  }

  void removeTask(DateTime date, String subjectId, String taskId) {
    final key = StudyState._dateKey(date);
    final subjects = List<StudySubject>.from(state.subjectsByDate[key] ?? []);
    final sIdx = subjects.indexWhere((s) => s.id == subjectId);
    if (sIdx == -1) return;
    final tasks = List<StudyTask>.from(subjects[sIdx].tasks)
      ..removeWhere((t) => t.id == taskId);
    subjects[sIdx] = subjects[sIdx].copyWith(tasks: tasks);
    state = state.copyWith(
      subjectsByDate: Map.from(state.subjectsByDate)..[key] = subjects,
    );
  }

  void addSubject(DateTime date, String name, {String difficulty = '중'}) {
    final key = StudyState._dateKey(date);
    final subjects = List<StudySubject>.from(state.subjectsByDate[key] ?? []);
    subjects.add(
      StudySubject(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        difficulty: difficulty,
      ),
    );
    state = state.copyWith(
      subjectsByDate: Map.from(state.subjectsByDate)..[key] = subjects,
    );
  }

  void removeSubject(DateTime date, String subjectId) {
    final key = StudyState._dateKey(date);
    final subjects = List<StudySubject>.from(state.subjectsByDate[key] ?? []);
    subjects.removeWhere((s) => s.id == subjectId);
    state = state.copyWith(
      subjectsByDate: Map.from(state.subjectsByDate)..[key] = subjects,
    );
  }
}

final studyProvider = StateNotifierProvider<StudyNotifier, StudyState>((ref) {
  final notifier = StudyNotifier(ref);
  ref.listen(dailyPlanProvider, (_, next) {
    final plans = next.valueOrNull ?? [];
    notifier.syncFromPlans(plans);
  });
  return notifier;
});

final todayAchievementProvider = Provider<({int completed, int total})>((ref) {
  return ref.watch(todayAchievementRealProvider);
});

final studyStreakProvider = Provider<int>((ref) => 0);
