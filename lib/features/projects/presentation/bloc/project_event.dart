import 'package:equatable/equatable.dart';

abstract class ProjectEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProjects extends ProjectEvent {}

class CreateProject extends ProjectEvent {
  final String name;
  final String? description;
  final String color;
  CreateProject({required this.name, this.description, required this.color});
  @override
  List<Object?> get props => [name, description, color];
}

class DeleteProject extends ProjectEvent {
  final String projectId;
  DeleteProject(this.projectId);
  @override
  List<Object?> get props => [projectId];
}