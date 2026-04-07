import '../repositories/project_repository.dart';

class DeleteProjectUseCase {
  final ProjectRepository repository;
  
  DeleteProjectUseCase(this.repository);

  Future<void> call(String projectId) {
    return repository.deleteProject(projectId);
  }
}