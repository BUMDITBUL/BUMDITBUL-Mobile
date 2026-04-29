import 'package:bumditbul_mobile/core/features/main/domain/entities/study_entities.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final displayMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});

final examDateProvider = StateProvider<DateTime?>((ref) {
  return DateTime.now().add(const Duration(days: 13));
});

class StudyState {
  final Map<String, List<StudySubject>> subjectsByDate;

  const StudyState({this.subjectsByDate = const {}});

  StudyState copyWith({Map<String, List<StudySubject>>? subjectsByDate}) {
    return StudyState(subjectsByDate: subjectsByDate ?? this.subjectsByDate);
  }

  List<StudySubject> getSubjectsForDate(DateTime date) {
    return subjectsByDate[_dateKey(date)] ?? [];
  }

  bool hasTasksOnDate(DateTime date) {
    final subjects = subjectsByDate[_dateKey(date)] ?? [];
    return subjects.any((s) => s.tasks.isNotEmpty);
  }

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class StudyNotifier extends StateNotifier<StudyState> {
  StudyNotifier() : super(const StudyState()) {
    _initMockData();
  }

  void _initMockData() {
    final today = DateTime.now();
    final key = StudyState._dateKey(today);
    state = StudyState(
      subjectsByDate: {
        key: [
          const StudySubject(
            id: '1',
            name: '수학',
            tasks: [
              StudyTask(id: '1-1', description: '교과서 96 ~ 106p'),
              StudyTask(id: '1-2', description: '문제집 45 ~ 50p'),
            ],
          ),
          const StudySubject(
            id: '2',
            name: '영어',
            tasks: [
              StudyTask(id: '2-1', description: '학습지 11 ~ 15p'),
            ],
          ),
          const StudySubject(
            id: '3',
            name: '과학',
            tasks: [
              StudyTask(id: '3-1', description: '교과서 95 ~ 106p'),
              StudyTask(id: '3-2', description: '평가문제 전범위'),
            ],
          ),
        ],
      },
    );
  }

  void toggleTask(DateTime date, String subjectId, String taskId) {
    final key = StudyState._dateKey(date);
    final subjects = List<StudySubject>.from(state.subjectsByDate[key] ?? []);

    final sIdx = subjects.indexWhere((s) => s.id == subjectId);
    if (sIdx == -1) return;

    final tasks = List<StudyTask>.from(subjects[sIdx].tasks);
    final tIdx = tasks.indexWhere((t) => t.id == taskId);
    if (tIdx == -1) return;

    tasks[tIdx] = tasks[tIdx].copyWith(isCompleted: !tasks[tIdx].isCompleted);
    subjects[sIdx] = subjects[sIdx].copyWith(tasks: tasks);

    state = state.copyWith(
      subjectsByDate: Map.from(state.subjectsByDate)..[key] = subjects,
    );
  }

  void addSubject(DateTime date, String name, {String difficulty = '중'}) {
    final key = StudyState._dateKey(date);
    final subjects = List<StudySubject>.from(state.subjectsByDate[key] ?? []);
    subjects.add(StudySubject(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      difficulty: difficulty,
    ));
    state = state.copyWith(
      subjectsByDate: Map.from(state.subjectsByDate)..[key] = subjects,
    );
  }

  void addTask(DateTime date, String subjectId, String description) {
    final key = StudyState._dateKey(date);
    final subjects = List<StudySubject>.from(state.subjectsByDate[key] ?? []);

    final sIdx = subjects.indexWhere((s) => s.id == subjectId);
    if (sIdx == -1) return;

    final tasks = List<StudyTask>.from(subjects[sIdx].tasks);
    tasks.add(StudyTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: description,
    ));
    subjects[sIdx] = subjects[sIdx].copyWith(tasks: tasks);

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

  void removeTask(DateTime date, String subjectId, String taskId) {
    final key = StudyState._dateKey(date);
    final subjects = List<StudySubject>.from(state.subjectsByDate[key] ?? []);

    final sIdx = subjects.indexWhere((s) => s.id == subjectId);
    if (sIdx == -1) return;

    final tasks = List<StudyTask>.from(subjects[sIdx].tasks);
    tasks.removeWhere((t) => t.id == taskId);
    subjects[sIdx] = subjects[sIdx].copyWith(tasks: tasks);

    state = state.copyWith(
      subjectsByDate: Map.from(state.subjectsByDate)..[key] = subjects,
    );
  }
}

final studyProvider = StateNotifierProvider<StudyNotifier, StudyState>(
  (ref) => StudyNotifier(),
);

final todayAchievementProvider =
    Provider<({int completed, int total})>((ref) {
  final studyState = ref.watch(studyProvider);
  final today = DateTime.now();
  final subjects = studyState.getSubjectsForDate(today);
  int total = 0;
  int completed = 0;
  for (final s in subjects) {
    total += s.tasks.length;
    completed += s.completedCount;
  }
  return (completed: completed, total: total);
});

final studyStreakProvider = Provider<int>((ref) => 5);
