import '../../domain/entities/task_entity.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.taskId,
    required super.userId,
    required super.username,
    super.avatarUrl,
    required super.content,
    required super.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'];
    return CommentModel(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      userId: json['user_id'] as String,
      username: profile?['username'] as String? ?? 'Unknown',
      avatarUrl: profile?['avatar_url'] as String?,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class TaskDetailModel extends TaskDetailEntity {
  const TaskDetailModel({
    required super.id,
    required super.columnId,
    required super.columnName,
    required super.projectId,
    required super.title,
    super.description,
    super.assigneeId,
    super.assigneeUsername,
    super.priority,
    super.dueDate,
    super.comments,
  });

  factory TaskDetailModel.fromJson(
    Map<String, dynamic> json,
    List<CommentModel> comments,
  ) {
    return TaskDetailModel(
      id: json['id'] as String,
      columnId: json['column_id'] as String,
      columnName: json['columns']?['name'] as String? ?? '',
      projectId: json['project_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      assigneeId: json['assignee_id'] as String?,
      assigneeUsername: json['profiles']?['username'] as String?,
      priority: json['priority'] as String? ?? 'medium',
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      comments: comments,
    );
  }
}