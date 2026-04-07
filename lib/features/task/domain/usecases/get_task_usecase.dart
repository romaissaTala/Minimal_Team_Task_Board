import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetTaskUseCase {
  final TaskRepository repository;
  GetTaskUseCase(this.repository);
  Future<TaskDetailEntity> call(String taskId) => repository.getTask(taskId);
}