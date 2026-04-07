import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/presence/data/datasources/presence_service.dart';
import '../../features/projects/data/datasources/project_remote_datasource.dart';
import '../../features/projects/data/repositories/project_repository_impl.dart';
import '../../features/projects/domain/repositories/project_repository.dart';
import '../../features/projects/domain/usecases/get_projects_usecase.dart';
import '../../features/projects/domain/usecases/create_project_usecase.dart';
import '../../features/projects/presentation/bloc/project_bloc.dart';
import '../../features/board/data/datasources/board_remote_datasource.dart';
import '../../features/board/data/repositories/board_repository_impl.dart';
import '../../features/board/domain/repositories/board_repository.dart';
import '../../features/board/domain/usecases/get_board_usecase.dart';
import '../../features/board/domain/usecases/move_task_usecase.dart';
import '../../features/board/presentation/bloc/board_bloc.dart';
import '../../features/task/data/datasources/task_remote_datasource.dart';
import '../../features/task/data/repositories/task_repository_impl.dart';
import '../../features/task/domain/repositories/task_repository.dart';
import '../../features/task/domain/usecases/get_task_usecase.dart';
import '../../features/task/domain/usecases/add_comment_usecase.dart';
import '../../features/task/domain/usecases/update_task_usecase.dart';
import '../../features/task/presentation/bloc/task_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final supabase = Supabase.instance.client;

  // External
  sl.registerLazySingleton(() => supabase);

  // ---- AUTH ----
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerFactory(() => AuthBloc(
        loginUseCase: sl(),
        registerUseCase: sl(),
        logoutUseCase: sl(),
      ));

  // ---- PROJECTS ----
  sl.registerLazySingleton<ProjectRemoteDataSource>(
    () => ProjectRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ProjectRepository>(
    () => ProjectRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetProjectsUseCase(sl()));
  sl.registerLazySingleton(() => CreateProjectUseCase(sl()));
  sl.registerFactory(() => ProjectBloc(
        getProjectsUseCase: sl(),
        createProjectUseCase: sl(),
      ));

  // ---- BOARD ----
  sl.registerLazySingleton<BoardRemoteDataSource>(
    () => BoardRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<BoardRepository>(
    () => BoardRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetBoardUseCase(sl()));
  sl.registerLazySingleton(() => MoveTaskUseCase(sl()));
  sl.registerFactory(() => BoardBloc(
        getBoardUseCase: sl(),
        moveTaskUseCase: sl(),
      ));

  // ---- TASK ----
  sl.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetTaskUseCase(sl()));
  sl.registerLazySingleton(() => AddCommentUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTaskUseCase(sl()));

  // Add this inside init(), before the AUTH section:
  sl.registerLazySingleton(() => PresenceService(sl()));
  sl.registerFactory(() => TaskBloc(
        getTaskUseCase: sl(),
        addCommentUseCase: sl(),
        updateTaskUseCase: sl(),
      ));
}
