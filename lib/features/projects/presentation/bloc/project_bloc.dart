import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_projects_usecase.dart';
import '../../domain/usecases/create_project_usecase.dart';
import 'project_event.dart';
import 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final GetProjectsUseCase getProjectsUseCase;
  final CreateProjectUseCase createProjectUseCase;

  ProjectBloc({
    required this.getProjectsUseCase,
    required this.createProjectUseCase,
  }) : super(ProjectInitial()) {
    on<LoadProjects>(_onLoad);
    on<CreateProject>(_onCreate);
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

  Future<void> _onCreate(CreateProject event, Emitter<ProjectState> emit) async {
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
}