class TaskModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final bool isDone;

  const TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.isDone,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'].toString(),
      userId: map['user_id'].toString(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isDone: map['is_done'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'is_done': isDone,
    };
  }
}