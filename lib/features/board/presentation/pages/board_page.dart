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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHighest,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _BoardSliverAppBar(
            projectName: widget.projectName,
            projectId: widget.projectId,
            isDark: isDark,
          ),
        ],
        body: BlocBuilder<BoardBloc, BoardState>(
          builder: (context, state) {
            if (state is BoardLoaded) {
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

              return Column(
                children: [
                  // Filter bar lives here, outside the SliverAppBar
                  _FilterBarRow(
                    filter: _filter,
                    onChanged: (f) => setState(() => _filter = f),
                    isDark: isDark,
                  ),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(12),
                      itemCount: filteredColumns.length,
                      itemBuilder: (context, index) {
                        return BoardColumnWidget(
                          column: filteredColumns[index],
                          allColumns: state.columns,
                          projectId: widget.projectId,
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// ── Board Sliver AppBar ───────────────────────────────────────────────────────

class _BoardSliverAppBar extends StatelessWidget {
  final String projectName;
  final String projectId;
  final bool isDark;

  const _BoardSliverAppBar({
    required this.projectName,
    required this.projectId,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 70,
      floating: false,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0F0F1A), const Color(0xFF1A1A2E)]
                : [const Color(0xFF6366F1), const Color(0xFF818CF8)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(isDark ? 0.3 : 0.25),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FlexibleSpaceBar(
          collapseMode: CollapseMode.pin,
          background: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Back button
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.all(8),
                      minimumSize: const Size(40, 40),
                    ),
                    icon: const Icon(Icons.arrow_back_ios_rounded,
                        color: Colors.white, size: 18),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 10),
                  // Project name + subtitle
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          projectName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Online members
                  OnlineMembersBar(projectId: projectId),
                  const SizedBox(width: 4),
                  // Refresh button
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.all(8),
                      minimumSize: const Size(40, 40),
                    ),
                    icon: const Icon(Icons.refresh_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () =>
                        context.read<BoardBloc>().add(LoadBoard(projectId)),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Filter bar row ────────────────────────────────────────────────────────────

class _FilterBarRow extends StatelessWidget {
  final TaskFilter filter;
  final ValueChanged<TaskFilter> onChanged;
  final bool isDark;

  const _FilterBarRow({
    required this.filter,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: BoardFilterBar(
        selected: filter,
        onChanged: onChanged,
      ),
    );
  }
}
