import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/board_entity.dart';
import '../../domain/usecases/get_board_usecase.dart';
import '../../domain/usecases/move_task_usecase.dart';
import '../../data/repositories/board_repository_impl.dart';
import '../../data/datasources/board_remote_datasource.dart';
import 'board_event.dart';
import 'board_state.dart';

class BoardBloc extends Bloc<BoardEvent, BoardState> {
  final GetBoardUseCase getBoardUseCase;
  final MoveTaskUseCase moveTaskUseCase;
  StreamSubscription? _realtimeSub;

  BoardBloc({
    required this.getBoardUseCase,
    required this.moveTaskUseCase,
  }) : super(BoardInitial()) {
    on<LoadBoard>(_onLoad);
    on<MoveTask>(_onMoveTask);
    on<AddTaskToColumn>(_onAddTask);
    on<BoardRealtimeUpdate>(_onRealtimeUpdate);
  }

  Future<void> _onLoad(LoadBoard event, Emitter<BoardState> emit) async {
    emit(BoardLoading());
    try {
      final columns = await getBoardUseCase(event.projectId);
      emit(BoardLoaded(columns: columns, projectId: event.projectId));

      // Subscribe to realtime updates
      _realtimeSub?.cancel();
      _realtimeSub = sl<BoardRemoteDataSource>()
          .watchTasks(event.projectId)
          .listen((_) => add(BoardRealtimeUpdate(event.projectId)));
    } catch (e) {
      emit(BoardError(e.toString()));
    }
  }

  Future<void> _onMoveTask(MoveTask event, Emitter<BoardState> emit) async {
    final current = state as BoardLoaded;

    // Optimistic update — move task in local state immediately
    final newColumns = _moveTaskOptimistically(
      columns: current.columns,
      taskId: event.taskId,
      fromColumnId: event.fromColumnId,
      toColumnId: event.toColumnId,
      fromIndex: event.fromIndex,
      toIndex: event.toIndex,
    );

    emit(BoardLoaded(columns: newColumns, projectId: current.projectId));

    // Calculate new order_index
    final targetColumn = newColumns.firstWhere((c) => c.id == event.toColumnId);
    final tasks = targetColumn.tasks;
    double newOrderIndex;

    if (tasks.isEmpty) {
      newOrderIndex = 1000.0;
    } else if (event.toIndex == 0) {
      newOrderIndex = tasks[0].orderIndex / 2;
    } else if (event.toIndex >= tasks.length - 1) {
      newOrderIndex = tasks.last.orderIndex + 1000.0;
    } else {
      newOrderIndex = (tasks[event.toIndex - 1].orderIndex +
          tasks[event.toIndex + 1].orderIndex) / 2;
    }

    try {
      await moveTaskUseCase(
        taskId: event.taskId,
        targetColumnId: event.toColumnId,
        newOrderIndex: newOrderIndex,
      );
    } catch (e) {
      // Revert on failure
      emit(BoardLoaded(columns: current.columns, projectId: current.projectId));
    }
  }

  Future<void> _onAddTask(AddTaskToColumn event, Emitter<BoardState> emit) async {
    final current = state as BoardLoaded;
    final column = current.columns.firstWhere((c) => c.id == event.columnId);
    final orderIndex = column.tasks.isEmpty
        ? 1000.0
        : column.tasks.last.orderIndex + 1000.0;

    try {
      await sl<BoardRemoteDataSource>().createTask(
        columnId: event.columnId,
        projectId: event.projectId,
        title: event.title,
        orderIndex: orderIndex,
      );
      add(BoardRealtimeUpdate(event.projectId));
    } catch (e) {
      // ignore
    }
  }

  Future<void> _onRealtimeUpdate(
    BoardRealtimeUpdate event,
    Emitter<BoardState> emit,
  ) async {
    try {
      final columns = await getBoardUseCase(event.projectId);
      emit(BoardLoaded(columns: columns, projectId: event.projectId));
    } catch (_) {}
  }

  List<ColumnEntity> _moveTaskOptimistically({
    required List<ColumnEntity> columns,
    required String taskId,
    required String fromColumnId,
    required String toColumnId,
    required int fromIndex,
    required int toIndex,
  }) {
    final result = List<ColumnEntity>.from(columns);

    final fromColIndex = result.indexWhere((c) => c.id == fromColumnId);
    final toColIndex = result.indexWhere((c) => c.id == toColumnId);
    if (fromColIndex == -1 || toColIndex == -1) return result;

    final fromTasks = List<TaskCardEntity>.from(result[fromColIndex].tasks);
    final task = fromTasks.removeAt(fromIndex);

    if (fromColumnId == toColumnId) {
      fromTasks.insert(toIndex, task);
      result[fromColIndex] = result[fromColIndex].copyWith(tasks: fromTasks);
    } else {
      final toTasks = List<TaskCardEntity>.from(result[toColIndex].tasks);
      toTasks.insert(toIndex, task);
      result[fromColIndex] = result[fromColIndex].copyWith(tasks: fromTasks);
      result[toColIndex] = result[toColIndex].copyWith(tasks: toTasks);
    }

    return result;
  }

  @override
  Future<void> close() {
    _realtimeSub?.cancel();
    return super.close();
  }
}