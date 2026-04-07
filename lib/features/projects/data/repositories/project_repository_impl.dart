import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_remote_datasource.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource _dataSource;
  ProjectRepositoryImpl(this._dataSource);

  @override
  Future<List<ProjectEntity>> getProjects() => _dataSource.getProjects();

  @override
  Future<ProjectEntity> createProject({
    required String name,
    String? description,
    required String color,
  }) => _dataSource.createProject(name: name, description: description, color: color);

  @override
  Future<void> deleteProject(String projectId) =>
      _dataSource.deleteProject(projectId);
}