class TaskModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final int durationMinutes;
  final bool isDone;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.isDone,
    required this.createdAt,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      durationMinutes: (map['duration_minutes'] as int?) ?? 0,
      isDone: (map['is_done'] as bool?) ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'duration_minutes': durationMinutes,
      'is_done': isDone,
    };
  }
}
