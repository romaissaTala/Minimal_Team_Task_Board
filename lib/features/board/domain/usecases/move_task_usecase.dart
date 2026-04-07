import '../repositories/board_repository.dart';

class MoveTaskUseCase {
  final BoardRepository repository;
  MoveTaskUseCase(this.repository);

  Future<void> call({
    required String taskId,
    required String targetColumnId,
    required double newOrderIndex,
  }) => repository.moveTask(
    taskId: taskId,
    targetColumnId: targetColumnId,
    newOrderIndex: newOrderIndex,
  );
}