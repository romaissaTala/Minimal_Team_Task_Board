import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';
import '../../domain/entities/task_entity.dart';

abstract class TaskRemoteDataSource {
  Future<TaskDetailEntity> getTask(String taskId);
  Future<CommentEntity> addComment({
    required String taskId,
    required String content,
  });
  Future<void> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? priority,
    DateTime? dueDate,
  });
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final SupabaseClient _client;
  TaskRemoteDataSourceImpl(this._client);

  @override
  Future<TaskDetailEntity> getTask(String taskId) async {
    final task = await _client
        .from('tasks')
        .select('*, profiles(username, avatar_url), columns(name)')
        .eq('id', taskId)
        .single();

    final commentsData = await _client
        .from('comments')
        .select('*, profiles(username, avatar_url)')
        .eq('task_id', taskId)
        .order('created_at');

    final comments = (commentsData as List)
        .map((c) => CommentModel.fromJson(c))
        .toList();

    return TaskDetailModel.fromJson(task, comments);
  }

  @override
  Future<CommentEntity> addComment({
    required String taskId,
    required String content,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final response = await _client.from('comments').insert({
      'task_id': taskId,
      'user_id': userId,
      'content': content,
    }).select('*, profiles(username, avatar_url)').single();

    return CommentModel.fromJson(response);
  }

  @override
  Future<void> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? priority,
    DateTime? dueDate,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (title != null) updates['title'] = title;
    if (description != null) updates['description'] = description;
    if (priority != null) updates['priority'] = priority;
    if (dueDate != null) updates['due_date'] = dueDate.toIso8601String();

    await _client.from('tasks').update(updates).eq('id', taskId);
  }
}