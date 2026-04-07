import 'package:equatable/equatable.dart';

abstract class TaskEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTask extends TaskEvent {
  final String taskId;
  LoadTask(this.taskId);
  @override
  List<Object?> get props => [taskId];
}

class AddComment extends TaskEvent {
  final String taskId;
  final String content;
  AddComment({required this.taskId, required this.content});
  @override
  List<Object?> get props => [taskId, content];
}

class UpdateTask extends TaskEvent {
  final String taskId;
  final String? title;
  final String? description;
  final String? priority;
  final DateTime? dueDate;
  UpdateTask({
    required this.taskId,
    this.title,
    this.description,
    this.priority,
    this.dueDate,
  });
  @override
  List<Object?> get props => [taskId, title, description, priority, dueDate];
}