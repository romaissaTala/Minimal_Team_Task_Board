import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/board_bloc.dart';
import '../bloc/board_event.dart';
import '../bloc/board_state.dart';
import '../widgets/board_column_widget.dart';
import '../widgets/board_filter_bar.dart';
import '../widgets/online_members_bar.dart';

class BoardPage extends StatelessWidget {
  final String projectId;
  final String projectName;

  const BoardPage({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BoardBloc>()..add(LoadBoard(projectId)),
      child: _BoardView(projectId: projectId, projectName: projectName),
    );
  }
}

class _BoardView extends StatefulWidget {
  // change to StatefulWidget
  final String projectId;
  final String projectName;
  const _BoardView({required this.projectId, required this.projectName});

  @override
  State<_BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<_BoardView> {
  TaskFilter _filter = TaskFilter.all;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHighest,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.projectName),
        backgroundColor: scheme.surface,
        actions: [
          OnlineMembersBar(projectId: widget.projectId),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                context.read<BoardBloc>().add(LoadBoard(widget.projectId)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: BoardFilterBar(
              selected: _filter,
              onChanged: (f) => setState(() => _filter = f),
            ),
          ),
        ),
      ),
      body: BlocBuilder<BoardBloc, BoardState>(
        builder: (context, state) {
          if (state is BoardLoaded) {
            // Apply filter to columns
            final filteredColumns = state.columns.map((col) {
              final filtered = col.tasks.where((task) {
                return switch (_filter) {
                  TaskFilter.all => true,
                  TaskFilter.high => task.priority == 'high',
                  TaskFilter.medium => task.priority == 'medium',
                  TaskFilter.low => task.priority == 'low',
                  TaskFilter.myTasks => task.assigneeId == currentUserId,
                  TaskFilter.overdue => task.dueDate != null &&
                      task.dueDate!.isBefore(DateTime.now()),
                };
              }).toList();
              return col.copyWith(tasks: filtered);
            }).toList();

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              itemCount: filteredColumns.length,
              itemBuilder: (context, index) {
                return BoardColumnWidget(
                  column: filteredColumns[index],
                  allColumns: state.columns, // pass original for move logic
                  projectId: widget.projectId,
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
