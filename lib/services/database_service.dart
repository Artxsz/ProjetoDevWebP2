import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/task_model.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<TaskModel>> getTasks() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return [];
    }

    final response = await _supabase
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return response.map((task) => TaskModel.fromMap(task)).toList();
  }

  Future<void> createTask(String title, String description) async {
    await _supabase.from('tasks').insert({
      'user_id': _supabase.auth.currentUser!.id,
      'title': title.trim(),
      'description': description.trim(),
      'is_done': false,
    });
  }

  Future<void> updateTask(
    TaskModel task, {
    String? title,
    String? description,
    bool? isDone,
  }) async {
    await _supabase.from('tasks').update({
      'title': title ?? task.title,
      'description': description ?? task.description,
      'is_done': isDone ?? task.isDone,
    }).eq('id', task.id);
  }

  Future<void> deleteTask(String id) async {
    await _supabase.from('tasks').delete().eq('id', id);
  }
}