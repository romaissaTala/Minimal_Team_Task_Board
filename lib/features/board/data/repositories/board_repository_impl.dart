import '../../domain/entities/board_entity.dart';
import '../../domain/repositories/board_repository.dart';
import '../datasources/board_remote_datasource.dart';

class BoardRepositoryImpl implements BoardRepository {
  final BoardRemoteDataSource _dataSource;
  BoardRepositoryImpl(this._dataSource);

  @override
  Future<List<ColumnEntity>> getBoard(String projectId) =>
      _dataSource.getBoard(projectId);

  @override
  Future<void> moveTask({
    required String taskId,
    required String targetColumnId,
    required double newOrderIndex,
  }) => _dataSource.moveTask(
    taskId: taskId,
    targetColumnId: targetColumnId,
    newOrderIndex: newOrderIndex,
  );

  @override
  Future<TaskCardEntity> createTask({
    required String columnId,
    required String projectId,
    required String title,
    required double orderIndex,
  }) => _dataSource.createTask(
    columnId: columnId,
    projectId: projectId,
    title: title,
    orderIndex: orderIndex,
  );

  @override
  Stream<List<Map<String, dynamic>>> watchTasks(String projectId) =>
      _dataSource.watchTasks(projectId);
}