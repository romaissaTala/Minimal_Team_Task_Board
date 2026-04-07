import 'package:equatable/equatable.dart';

class ProjectEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String ownerId;
  final String color;
  final DateTime createdAt;
  final List<String> memberIds;

  const ProjectEntity({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    this.color = '#6366F1',
    required this.createdAt,
    this.memberIds = const [],
  });

  @override
  List<Object?> get props => [id, name, ownerId];
}