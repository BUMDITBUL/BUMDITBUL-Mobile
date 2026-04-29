class StudyTask {
  final String id;
  final String description;
  final bool isCompleted;

  const StudyTask({
    required this.id,
    required this.description,
    this.isCompleted = false,
  });

  StudyTask copyWith({String? id, String? description, bool? isCompleted}) {
    return StudyTask(
      id: id ?? this.id,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class StudySubject {
  final String id;
  final String name;
  final String difficulty; // '상', '중', '하' — 기본값 '중'
  final List<StudyTask> tasks;

  const StudySubject({
    required this.id,
    required this.name,
    this.difficulty = '중',
    this.tasks = const [],
  });

  StudySubject copyWith({
    String? id,
    String? name,
    String? difficulty,
    List<StudyTask>? tasks,
  }) {
    return StudySubject(
      id: id ?? this.id,
      name: name ?? this.name,
      difficulty: difficulty ?? this.difficulty,
      tasks: tasks ?? this.tasks,
    );
  }

  bool get isAllCompleted =>
      tasks.isNotEmpty && tasks.every((t) => t.isCompleted);

  int get completedCount => tasks.where((t) => t.isCompleted).length;
}
