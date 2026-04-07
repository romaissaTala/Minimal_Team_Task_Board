import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_datasource.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _dataSource;
  TaskRepositoryImpl(this._dataSource);

  @override
  Future<TaskDetailEntity> getTask(String taskId) =>
      _dataSource.getTask(taskId);

  @override
  Future<CommentEntity> addComment({
    required String taskId,
    required String content,
  }) => _dataSource.addComment(taskId: taskId, content: content);

  @override
  Future<void> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? priority,
    DateTime? dueDate,
  }) => _dataSource.updateTask(
    taskId: taskId,
    title: title,
    description: description,
    priority: priority,
    dueDate: dueDate,
  );
}