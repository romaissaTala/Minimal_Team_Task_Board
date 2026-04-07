import '../../domain/entities/project_entity.dart';

class ProjectModel extends ProjectEntity {
  const ProjectModel({
    required super.id,
    required super.name,
    super.description,
    required super.ownerId,
    super.color,
    required super.createdAt,
    super.memberIds,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      ownerId: json['owner_id'] as String,
      color: json['color'] as String? ?? '#6366F1',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'owner_id': ownerId,
    'color': color,
  };
}