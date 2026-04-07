import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/board_entity.dart';

class TaskCardWidget extends StatelessWidget {
  final TaskCardEntity task;
  final bool isDragging;
  final String projectId; // ADD THIS

  const TaskCardWidget({
    super.key,
    required this.task,
    this.isDragging = false,
    required this.projectId, // ADD THIS
  });

  Color get _priorityColor {
    return switch (task.priority) {
      'high' => AppTheme.priorityHigh,
      'low' => AppTheme.priorityLow,
      _ => AppTheme.priorityMedium,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: isDragging ? null : () => context.push(
        '/task/${task.id}',
        extra: {'projectId': projectId}, // ADD THIS
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDragging ? scheme.surface.withOpacity(0.9) : scheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDragging ? 0.12 : 0.04),
              blurRadius: isDragging ? 16 : 4,
              offset: Offset(0, isDragging ? 8 : 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover color bar (optional)
            if (task.coverColor != null)
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Color(
                    int.parse(task.coverColor!.replaceFirst('#', '0xFF')),
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Priority dot + title
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 5, right: 8),
                        decoration: BoxDecoration(
                          color: _priorityColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (task.description != null && task.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      task.description!,
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurface.withOpacity(0.5),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 10),

                  // Footer: assignee + due date + comment count
                  Row(
                    children: [
                      if (task.assigneeUsername != null)
                        _buildAvatar(task.assigneeUsername!, scheme),

                      const Spacer(),

                      if (task.dueDate != null) ...[
                        Icon(
                          Icons.schedule_rounded,
                          size: 11,
                          color: _isDueSoon()
                              ? AppTheme.priorityHigh
                              : scheme.onSurface.withOpacity(0.4),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          _formatDate(task.dueDate!),
                          style: TextStyle(
                            fontSize: 10,
                            color: _isDueSoon()
                                ? AppTheme.priorityHigh
                                : scheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],

                      if (task.commentCount > 0) ...[
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 11,
                          color: scheme.onSurface.withOpacity(0.4),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${task.commentCount}',
                          style: TextStyle(
                            fontSize: 10,
                            color: scheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String username, ColorScheme scheme) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          username[0].toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppTheme.primary,
          ),
        ),
      ),
    );
  }

  bool _isDueSoon() {
    if (task.dueDate == null) return false;
    return task.dueDate!.difference(DateTime.now()).inDays <= 1;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month) return 'Today';
    if (date.day == now.day + 1 && date.month == now.month) return 'Tomorrow';
    return '${date.day}/${date.month}';
  }
}