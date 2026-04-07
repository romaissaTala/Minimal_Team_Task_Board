import 'package:equatable/equatable.dart';
import '../../domain/entities/project_entity.dart';

abstract class ProjectState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProjectInitial extends ProjectState {}
class ProjectLoading extends ProjectState {}
class ProjectError extends ProjectState {
  final String message;
  ProjectError(this.message);
  @override
  List<Object?> get props => [message];
}

class ProjectsLoaded extends ProjectState {
  final List<ProjectEntity> projects;
  ProjectsLoaded(this.projects);
  @override
  List<Object?> get props => [projects];
}