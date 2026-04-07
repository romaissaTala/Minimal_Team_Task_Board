import '../entities/board_entity.dart';

abstract class BoardRepository {
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