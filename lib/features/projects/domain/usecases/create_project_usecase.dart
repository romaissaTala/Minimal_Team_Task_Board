import '../entities/project_entity.dart';
import '../repositories/project_repository.dart';

class CreateProjectUseCase {
  final ProjectRepository repository;
  CreateProjectUseCase(this.repository);

  Future<ProjectEntity> call({
    required String name,
    String? description,
    required String color,
  }) => repository.createProject(name: name, description: description, color: color);
}