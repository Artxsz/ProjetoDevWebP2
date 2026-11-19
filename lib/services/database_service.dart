import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';

class DatabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<TaskModel>> getTasks() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((item) => TaskModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createTask(
    String title,
    String description,
    int durationMinutes,
  ) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuário não autenticado');

    await _client.from('tasks').insert({
      'user_id': userId,
      'title': title.trim(),
      'description': description.trim(),
      'duration_minutes': durationMinutes,
      'is_done': false,
    });
  }

  Future<void> updateTask(
    TaskModel task, {
    String? title,
    String? description,
    int? durationMinutes,
    bool? isDone,
  }) async {
    final updates = <String, dynamic>{};
    if (title != null) updates['title'] = title.trim();
    if (description != null) updates['description'] = description.trim();
    if (durationMinutes != null) updates['duration_minutes'] = durationMinutes;
    if (isDone != null) updates['is_done'] = isDone;

    if (updates.isEmpty) return;

    await _client.from('tasks').update(updates).eq('id', task.id);
  }

  Future<void> deleteTask(String id) async {
    await _client.from('tasks').delete().eq('id', id);
  }
}
