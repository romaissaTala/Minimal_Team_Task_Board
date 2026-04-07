import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_task_usecase.dart';
import '../../domain/usecases/add_comment_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_entity.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTaskUseCase getTaskUseCase;
  final AddCommentUseCase addCommentUseCase;
  final UpdateTaskUseCase updateTaskUseCase;

  TaskBloc({
    required this.getTaskUseCase,
    required this.addCommentUseCase,
    required this.updateTaskUseCase,
  }) : super(TaskInitial()) {
    on<LoadTask>(_onLoad);
    on<AddComment>(_onAddComment);
    on<UpdateTask>(_onUpdate);
  }

  Future<void> _onLoad(LoadTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final task = await getTaskUseCase(event.taskId);
      emit(TaskLoaded(task));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onAddComment(AddComment event, Emitter<TaskState> emit) async {
    final current = state;
    if (current is! TaskLoaded) return;

    try {
      final comment = await addCommentUseCase(
        taskId: event.taskId,
        content: event.content,
      );
      // Optimistic update
      final updatedTask = TaskDetailEntity(
        id: current.task.id,
        columnId: current.task.columnId,
        columnName: current.task.columnName,
        projectId: current.task.projectId,
        title: current.task.title,
        description: current.task.description,
        assigneeId: current.task.assigneeId,
        assigneeUsername: current.task.assigneeUsername,
        priority: current.task.priority,
        dueDate: current.task.dueDate,
        comments: [...current.task.comments, comment],
      );
      emit(TaskLoaded(updatedTask));
    } catch (e) {
      // Comment failed silently — reload
      add(LoadTask(event.taskId));
    }
  }

  Future<void> _onUpdate(UpdateTask event, Emitter<TaskState> emit) async {
    final current = state;
    if (current is! TaskLoaded) return;

    emit(TaskUpdating(current.task));
    try {
      await updateTaskUseCase(
        taskId: event.taskId,
        title: event.title,
        description: event.description,
        priority: event.priority,
        dueDate: event.dueDate,
      );
      add(LoadTask(event.taskId));
    } catch (e) {
      emit(TaskLoaded(current.task));
    }
  }
}