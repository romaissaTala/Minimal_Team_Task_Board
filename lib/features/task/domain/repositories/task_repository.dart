import '../entities/task_entity.dart';

abstract class TaskRepository {
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