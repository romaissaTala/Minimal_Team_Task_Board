import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/delete_project_usecase.dart';
import '../../domain/usecases/get_projects_usecase.dart';
import '../../domain/usecases/create_project_usecase.dart';
import 'project_event.dart';
import 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final GetProjectsUseCase getProjectsUseCase;
  final CreateProjectUseCase createProjectUseCase;
  final DeleteProjectUseCase deleteProjectUseCase;
  ProjectBloc({
    required this.getProjectsUseCase,
    required this.createProjectUseCase,
    required this.deleteProjectUseCase,
  }) : super(ProjectInitial()) {
    on<LoadProjects>(_onLoad);
    on<CreateProject>(_onCreate);
    on<DeleteProject>(_onDelete);
  }

  Future<void> _onLoad(LoadProjects event, Emitter<ProjectState> emit) async {
    emit(ProjectLoading());
    try {
      final projects = await getProjectsUseCase();
      emit(ProjectsLoaded(projects));
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  Future<void> _onCreate(
      CreateProject event, Emitter<ProjectState> emit) async {
    try {
      await createProjectUseCase(
        name: event.name,
        description: event.description,
        color: event.color,
      );
      add(LoadProjects());
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  Future<void> _onDelete(
      DeleteProject event, Emitter<ProjectState> emit) async {
    try {
      await deleteProjectUseCase(event.projectId);
      add(LoadProjects()); // Reload the list after deletion
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }
}
