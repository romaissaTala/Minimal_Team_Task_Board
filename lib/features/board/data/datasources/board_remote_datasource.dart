import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/board_model.dart';
import '../../domain/entities/board_entity.dart';

abstract class BoardRemoteDataSource {
  Future<List<ColumnEntity>> getBoard(String projectId);
  Future<void> moveTask({
    required String taskId,
    required String targetColumnId,
    required double newOrderIndex,
  });
  Future<TaskCardEntity> createTask({
    required String columnId,
    required String projectId,
    required String title,
    required double orderIndex,
  });
  Stream<List<Map<String, dynamic>>> watchTasks(String projectId);
}

class BoardRemoteDataSourceImpl implements BoardRemoteDataSource {
  final SupabaseClient _client;
  BoardRemoteDataSourceImpl(this._client);

  @override
  Future<List<ColumnEntity>> getBoard(String projectId) async {
    // Get columns
    final columns = await _client
        .from('columns')
        .select()
        .eq('project_id', projectId)
        .order('order_index');

    // Get tasks with assignee profile info - specify which relationship to use
    final tasks = await _client
        .from('tasks')
        .select('''
          *,
          assignee:profiles!tasks_assignee_id_fkey(
            username,
            avatar_url
          ),
          created_by_profile:profiles!tasks_created_by_fkey(
            username,
            avatar_url
          )
        ''')
        .eq('project_id', projectId)
        .order('order_index');

    final columnModels = (columns as List)
        .map((c) => ColumnModel.fromJson(c))
        .toList();

    final taskModels = (tasks as List)
        .map((t) => TaskCardModel.fromJsonWithRelations(t))
        .toList();

    // Group tasks into columns
    return columnModels.map((col) {
      final colTasks = taskModels
          .where((t) => t.columnId == col.id)
          .toList()
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      return col.copyWith(tasks: colTasks);
    }).toList();
  }

  @override
  Future<void> moveTask({
    required String taskId,
    required String targetColumnId,
    required double newOrderIndex,
  }) async {
    await _client.from('tasks').update({
      'column_id': targetColumnId,
      'order_index': newOrderIndex,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', taskId);
  }

  @override
  Future<TaskCardEntity> createTask({
    required String columnId,
    required String projectId,
    required String title,
    required double orderIndex,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final response = await _client.from('tasks').insert({
      'column_id': columnId,
      'project_id': projectId,
      'title': title,
      'order_index': orderIndex,
      'created_by': userId,
    }).select('''
      *,
      assignee:profiles!tasks_assignee_id_fkey(
        username,
        avatar_url
      ),
      created_by_profile:profiles!tasks_created_by_fkey(
        username,
        avatar_url
      )
    ''').single();

    return TaskCardModel.fromJsonWithRelations(response);
  }

  @override
  Stream<List<Map<String, dynamic>>> watchTasks(String projectId) {
    return _client
        .from('tasks')
        .stream(primaryKey: ['id'])
        .eq('project_id', projectId)
        .order('order_index');
  }
}