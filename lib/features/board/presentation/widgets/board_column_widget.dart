import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/board_entity.dart';
import '../bloc/board_bloc.dart';
import '../bloc/board_event.dart';
import 'task_card_widget.dart';

/// BoardColumnWidget — renders one Kanban column.
/// 
/// How drag & drop works here:
/// - Each column is a DragTarget<Map> that accepts task data
/// - Each task card is wrapped in a LongPressDraggable
/// - When dropped, we calculate position (toIndex) by comparing
///   the drop Y position against each task's position
/// - We dispatch MoveTask to the BLoC which does optimistic update
class BoardColumnWidget extends StatefulWidget {
  final ColumnEntity column;
  final List<ColumnEntity> allColumns;
  final String projectId;

  const BoardColumnWidget({
    super.key,
    required this.column,
    required this.allColumns,
    required this.projectId,
  });

  @override
  State<BoardColumnWidget> createState() => _BoardColumnWidgetState();
}

class _BoardColumnWidgetState extends State<BoardColumnWidget> {
  bool _isDragOver = false;
  final _addTaskCtrl = TextEditingController();
  bool _showAddTask = false;

  Color get _columnColor {
    try {
      return Color(
        int.parse(widget.column.color.replaceFirst('#', '0xFF')),
      );
    } catch (_) {
      return AppTheme.primary;
    }
  }

  @override
  void dispose() {
    _addTaskCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          // Column header
          _buildHeader(scheme),
          const SizedBox(height: 8),

          // Tasks drop area
          Expanded(
            child: DragTarget<Map<String, dynamic>>(
              onWillAcceptWithDetails: (details) {
                setState(() => _isDragOver = true);
                return details.data['columnId'] != widget.column.id ||
                    widget.column.tasks.length > 1;
              },
              onLeave: (_) => setState(() => _isDragOver = false),
              onAcceptWithDetails: (details) {
                setState(() => _isDragOver = false);
                final data = details.data;
                context.read<BoardBloc>().add(MoveTask(
                  taskId: data['taskId'] as String,
                  fromColumnId: data['columnId'] as String,
                  toColumnId: widget.column.id,
                  fromIndex: data['index'] as int,
                  toIndex: widget.column.tasks.length,
                ));
              },
              builder: (context, candidateData, rejectedData) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: _isDragOver
                        ? _columnColor.withOpacity(0.08)
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isDragOver
                          ? _columnColor.withOpacity(0.4)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: ListView(
                      padding: const EdgeInsets.all(8),
                      children: [
                        // Task cards
                        ...widget.column.tasks.asMap().entries.map((entry) {
                          final index = entry.key;
                          final task = entry.value;

                          return _buildDraggableTask(task, index, scheme);
                        }),

                        // Add task area
                        if (_showAddTask) _buildAddTaskField(context, scheme),

                        // Add task button
                        if (!_showAddTask)
                          _buildAddButton(scheme),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: _columnColor, width: 4),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.column.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: scheme.onSurface,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _columnColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${widget.column.tasks.length}',
              style: TextStyle(
                color: _columnColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableTask(TaskCardEntity task, int index, ColorScheme scheme) {
    return LongPressDraggable<Map<String, dynamic>>(
      // Data passed to DragTarget when dropped
      data: {
        'taskId': task.id,
        'columnId': widget.column.id,
        'index': index,
      },
      // What appears under the user's finger while dragging
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 260,
          child:  TaskCardWidget(
          task: task, 
          isDragging: true,
          projectId: widget.projectId, // ADD THIS
        ),
        ),
      ),
      // Shows a greyed-out placeholder while the card is being dragged
      childWhenDragging: Opacity(
        opacity: 0.3,
        child:  TaskCardWidget(
          task: task, 
          projectId: widget.projectId, // ADD THIS
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: DragTarget<Map<String, dynamic>>(
          onWillAcceptWithDetails: (details) =>
              details.data['taskId'] != task.id,
          onAcceptWithDetails: (details) {
            final data = details.data;
            context.read<BoardBloc>().add(MoveTask(
              taskId: data['taskId'] as String,
              fromColumnId: data['columnId'] as String,
              toColumnId: widget.column.id,
              fromIndex: data['index'] as int,
              toIndex: index,
            ));
          },
          builder: (context, candidateData, _) {
            final isTarget = candidateData.isNotEmpty;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isTarget
                      ? _columnColor.withOpacity(0.6)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child:  TaskCardWidget(
          task: task, 
          projectId: widget.projectId, // ADD THIS
        ),
            );
          },
        ),
      ),
    )
    .animate()
    .fadeIn(delay: Duration(milliseconds: 50 * index), duration: 300.ms)
    .slideY(begin: 0.1, end: 0);
  }

  Widget _buildAddTaskField(BuildContext context, ColorScheme scheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _columnColor, width: 1.5),
      ),
      child: Column(
        children: [
          TextField(
            controller: _addTaskCtrl,
            autofocus: true,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Task title...',
              border: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
            ),
            style: const TextStyle(fontSize: 14),
            onSubmitted: (v) => _submitTask(context, v),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _showAddTask = false;
                    _addTaskCtrl.clear();
                  });
                },
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                ),
                onPressed: () => _submitTask(context, _addTaskCtrl.text),
                child: const Text('Add', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(ColorScheme scheme) {
    return InkWell(
      onTap: () => setState(() => _showAddTask = true),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(Icons.add_circle_outline, size: 18, color: scheme.onSurface.withOpacity(0.4)),
            const SizedBox(width: 6),
            Text(
              'Add task',
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitTask(BuildContext context, String title) {
    if (title.trim().isEmpty) return;
    context.read<BoardBloc>().add(AddTaskToColumn(
      columnId: widget.column.id,
      projectId: widget.projectId,
      title: title.trim(),
    ));
    setState(() {
      _showAddTask = false;
      _addTaskCtrl.clear();
    });
  }
}