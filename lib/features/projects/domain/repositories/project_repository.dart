import '../entities/project_entity.dart';

abstract class ProjectRepository {
  Future<List<ProjectEntity>> getProjects();
  Future<ProjectEntity> createProject({
    required String name,
    String? description,
    required String color,
  });
  Future<void> deleteProject(String projectId);
}