import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:minimal_team_task_board/features/board/domain/entities/board_entity.dart';
import 'package:minimal_team_task_board/features/board/domain/usecases/get_board_usecase.dart';
import 'package:minimal_team_task_board/features/board/domain/usecases/move_task_usecase.dart';
import 'package:minimal_team_task_board/features/board/presentation/bloc/board_bloc.dart';
import 'package:minimal_team_task_board/features/board/presentation/bloc/board_event.dart';
import 'package:minimal_team_task_board/features/board/presentation/bloc/board_state.dart';

class MockGetBoardUseCase extends Mock implements GetBoardUseCase {}
class MockMoveTaskUseCase extends Mock implements MoveTaskUseCase {}

void main() {
  late BoardBloc boardBloc;
  late MockGetBoardUseCase getBoardUseCase;
  late MockMoveTaskUseCase moveTaskUseCase;

  // Test fixtures
  final testColumns = [
    const ColumnEntity(
      id: 'col-1',
      projectId: 'proj-1',
      name: 'To Do',
      orderIndex: 0,
      tasks: [
        TaskCardEntity(
          id: 'task-1',
          columnId: 'col-1',
          projectId: 'proj-1',
          title: 'Test task',
          orderIndex: 1000,
        ),
      ],
    ),
    const ColumnEntity(
      id: 'col-2',
      projectId: 'proj-1',
      name: 'In Progress',
      orderIndex: 1,
      tasks: [],
    ),
  ];

  setUp(() {
    getBoardUseCase = MockGetBoardUseCase();
    moveTaskUseCase = MockMoveTaskUseCase();
    boardBloc = BoardBloc(
      getBoardUseCase: getBoardUseCase,
      moveTaskUseCase: moveTaskUseCase,
    );
  });

  tearDown(() => boardBloc.close());

  group('BoardBloc — LoadBoard', () {
    blocTest<BoardBloc, BoardState>(
      'emits [BoardLoading, BoardLoaded] when load succeeds',
      build: () {
        when(() => getBoardUseCase('proj-1'))
            .thenAnswer((_) async => testColumns);
        return boardBloc;
      },
      act: (bloc) => bloc.add(LoadBoard('proj-1')),
      expect: () => [
        isA<BoardLoading>(),
        isA<BoardLoaded>()
          .having((s) => s.columns.length, 'columns count', 2),
      ],
    );
  });

  group('BoardBloc — MoveTask (optimistic update)', () {
    blocTest<BoardBloc, BoardState>(
      'immediately updates UI before server call completes',
      build: () {
        when(() => getBoardUseCase('proj-1'))
            .thenAnswer((_) async => testColumns);
        when(() => moveTaskUseCase(
          taskId: any(named: 'taskId'),
          targetColumnId: any(named: 'targetColumnId'),
          newOrderIndex: any(named: 'newOrderIndex'),
        )).thenAnswer((_) async {});
        return boardBloc;
      },
      seed: () => BoardLoaded(columns: testColumns, projectId: 'proj-1'),
      act: (bloc) => bloc.add(MoveTask(
        taskId: 'task-1',
        fromColumnId: 'col-1',
        toColumnId: 'col-2',
        fromIndex: 0,
        toIndex: 0,
      )),
      expect: () => [
        // Optimistic state — task should now be in col-2
        isA<BoardLoaded>().having(
          (s) => s.columns.firstWhere((c) => c.id == 'col-2').tasks.length,
          'task moved to col-2',
          1,
        ),
      ],
    );
  });
}