import '../../domain/entities/board_entity.dart';

class TaskCardModel extends TaskCardEntity {
  const TaskCardModel({
    required super.id,
    required super.columnId,
    required super.projectId,
    required super.title,
    super.description,
    super.assigneeId,
    super.assigneeUsername,
    super.assigneeAvatarUrl,
    super.priority,
    super.dueDate,
    required super.orderIndex,
    super.coverColor,
    super.commentCount,
  });

  factory TaskCardModel.fromJson(Map<String, dynamic> json) {
    // Handle the nested assignee relationship
    final assignee = json['assignee'] as Map<String, dynamic>?;
    final createdByProfile =
        json['created_by_profile'] as Map<String, dynamic>?;

    return TaskCardModel(
      id: json['id'] as String,
      columnId: json['column_id'] as String,
      projectId: json['project_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      assigneeId: json['assignee_id'] as String?,
      assigneeUsername: assignee?['username'] as String?,
      assigneeAvatarUrl: assignee?['avatar_url'] as String?,
      priority: json['priority'] as String? ?? 'medium',
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      orderIndex: (json['order_index'] as num).toDouble(),
      coverColor: json['cover_color'] as String?,
      commentCount: json['comment_count'] as int? ?? 0,
    );
  }

  // Alternative factory if you want to include created_by info
  factory TaskCardModel.fromJsonWithRelations(Map<String, dynamic> json) {
    final assignee = json['assignee'] as Map<String, dynamic>?;

    return TaskCardModel(
      id: json['id'] as String,
      columnId: json['column_id'] as String,
      projectId: json['project_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      assigneeId: json['assignee_id'] as String?,
      assigneeUsername: assignee?['username'] as String?,
      assigneeAvatarUrl: assignee?['avatar_url'] as String?,
      priority: json['priority'] as String? ?? 'medium',
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      orderIndex: (json['order_index'] as num).toDouble(),
      coverColor: json['cover_color'] as String?,
      commentCount: json['comment_count'] as int? ?? 0,
    );
  }
}

class ColumnModel extends ColumnEntity {
  const ColumnModel({
    required super.id,
    required super.projectId,
    required super.name,
    super.color,
    required super.orderIndex,
    super.tasks,
  });

  factory ColumnModel.fromJson(Map<String, dynamic> json) {
    return ColumnModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      name: json['name'] as String,
      color: json['color'] as String? ?? '#94A3B8',
      orderIndex: (json['order_index'] as num).toDouble(),
    );
  }
}
