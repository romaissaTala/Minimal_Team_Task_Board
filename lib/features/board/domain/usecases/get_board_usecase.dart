import '../entities/board_entity.dart';
import '../repositories/board_repository.dart';

class GetBoardUseCase {
  final BoardRepository repository;
  GetBoardUseCase(this.repository);

  Future<List<ColumnEntity>> call(String projectId) =>
      repository.getBoard(projectId);
}