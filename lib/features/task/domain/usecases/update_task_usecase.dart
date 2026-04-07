import '../repositories/task_repository.dart';

class UpdateTaskUseCase {
  final TaskRepository repository;
  UpdateTaskUseCase(this.repository);
  Future<void> call({
    required String taskId,
    String? title,
    String? description,
    String? priority,
    DateTime? dueDate,
  }) => repository.updateTask(
    taskId: taskId,
    title: title,
    description: description,
    priority: priority,
    dueDate: dueDate,
  );
}