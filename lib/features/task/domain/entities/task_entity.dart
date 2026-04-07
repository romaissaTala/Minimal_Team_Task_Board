import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String id;
  final String taskId;
  final String userId;
  final String username;
  final String? avatarUrl;
  final String content;
  final DateTime createdAt;

  const CommentEntity({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.content,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id];
}

class TaskDetailEntity extends Equatable {
  final String id;
  final String columnId;
  final String columnName;
  final String projectId;
  final String title;
  final String? description;
  final String? assigneeId;
  final String? assigneeUsername;
  final String priority;
  final DateTime? dueDate;
  final List<CommentEntity> comments;

  const TaskDetailEntity({
    required this.id,
    required this.columnId,
    required this.columnName,
    required this.projectId,
    required this.title,
    this.description,
    this.assigneeId,
    this.assigneeUsername,
    this.priority = 'medium',
    this.dueDate,
    this.comments = const [],
  });

  @override
  List<Object?> get props => [id];
}