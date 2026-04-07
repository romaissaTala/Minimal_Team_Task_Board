import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class AddCommentUseCase {
  final TaskRepository repository;
  AddCommentUseCase(this.repository);
  Future<CommentEntity> call({
    required String taskId,
    required String content,
  }) => repository.addComment(taskId: taskId, content: content);
}