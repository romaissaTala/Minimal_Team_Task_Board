import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';

abstract class TaskState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}
class TaskLoading extends TaskState {}
class TaskError extends TaskState {
  final String message;
  TaskError(this.message);
  @override
  List<Object?> get props => [message];
}

class TaskLoaded extends TaskState {
  final TaskDetailEntity task;
  TaskLoaded(this.task);
  @override
  List<Object?> get props => [task];
}

class TaskUpdating extends TaskState {
  final TaskDetailEntity task;
  TaskUpdating(this.task);
  @override
  List<Object?> get props => [task];
}