import 'package:equatable/equatable.dart';

class ColumnEntity extends Equatable {
  final String id;
  final String projectId;
  final String name;
  final String color;
  final double orderIndex;
  final List<TaskCardEntity> tasks;

  const ColumnEntity({
    required this.id,
    required this.projectId,
    required this.name,
    this.color = '#94A3B8',
    required this.orderIndex,
    this.tasks = const [],
  });

  ColumnEntity copyWith({List<TaskCardEntity>? tasks}) {
    return ColumnEntity(
      id: id,
      projectId: projectId,
      name: name,
      color: color,
      orderIndex: orderIndex,
      tasks: tasks ?? this.tasks,
    );
  }

  @override
  List<Object?> get props => [id, projectId, name, orderIndex, tasks];
}

class TaskCardEntity extends Equatable {
  final String id;
  final String columnId;
  final String projectId;
  final String title;
  final String? description;
  final String? assigneeId;
  final String? assigneeUsername;
  final String? assigneeAvatarUrl;
  final String priority;
  final DateTime? dueDate;
  final double orderIndex;
  final String? coverColor;
  final int commentCount;

  const TaskCardEntity({
    required this.id,
    required this.columnId,
    required this.projectId,
    required this.title,
    this.description,
    this.assigneeId,
    this.assigneeUsername,
    this.assigneeAvatarUrl,
    this.priority = 'medium',
    this.dueDate,
    required this.orderIndex,
    this.coverColor,
    this.commentCount = 0,
  });

  @override
  List<Object?> get props => [id, columnId, title, orderIndex, priority];
}