import '../entities/project_entity.dart';
import '../repositories/project_repository.dart';

class GetProjectsUseCase {
  final ProjectRepository repository;
  GetProjectsUseCase(this.repository);

  Future<List<ProjectEntity>> call() => repository.getProjects();
}