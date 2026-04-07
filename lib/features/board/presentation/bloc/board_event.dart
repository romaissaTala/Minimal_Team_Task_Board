import 'package:equatable/equatable.dart';

abstract class BoardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadBoard extends BoardEvent {
  final String projectId;
  LoadBoard(this.projectId);
  @override
  List<Object?> get props => [projectId];
}

class MoveTask extends BoardEvent {
  final String taskId;
  final String fromColumnId;
  final String toColumnId;
  final int fromIndex;
  final int toIndex;

  MoveTask({
    required this.taskId,
    required this.fromColumnId,
    required this.toColumnId,
    required this.fromIndex,
    required this.toIndex,
  });

  @override
  List<Object?> get props => [taskId, fromColumnId, toColumnId, fromIndex, toIndex];
}

class AddTaskToColumn extends BoardEvent {
  final String columnId;
  final String projectId;
  final String title;
  AddTaskToColumn({
    required this.columnId,
    required this.projectId,
    required this.title,
  });
  @override
  List<Object?> get props => [columnId, projectId, title];
}

class BoardRealtimeUpdate extends BoardEvent {
  final String projectId;
  BoardRealtimeUpdate(this.projectId);
  @override
  List<Object?> get props => [projectId];
}