import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

enum TaskFilter { all, high, medium, low, myTasks, overdue }

class BoardFilterBar extends StatefulWidget {
  final TaskFilter selected;
  final ValueChanged<TaskFilter> onChanged;

  const BoardFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<BoardFilterBar> createState() => _BoardFilterBarState();
}

class _BoardFilterBarState extends State<BoardFilterBar> {
  static const _filters = [
    (TaskFilter.all, 'All', null),
    (TaskFilter.myTasks, 'Mine', Icons.person_rounded),
    (TaskFilter.high, 'High', Icons.flag_rounded),
    (TaskFilter.medium, 'Medium', Icons.flag_rounded),
    (TaskFilter.low, 'Low', Icons.flag_rounded),
    (TaskFilter.overdue, 'Overdue', Icons.schedule_rounded),
  ];

  Color _filterColor(TaskFilter f) => switch (f) {
    TaskFilter.high => AppTheme.priorityHigh,
    TaskFilter.medium => AppTheme.priorityMedium,
    TaskFilter.low => AppTheme.priorityLow,
    TaskFilter.overdue => Colors.orange,
    TaskFilter.myTasks => AppTheme.primary,
    _ => AppTheme.primary,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final (filter, label, icon) = _filters[i];
          final isSelected = widget.selected == filter;
          final color = _filterColor(filter);

          return GestureDetector(
            onTap: () => widget.onChanged(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? color : scheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? color : scheme.outline.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 13,
                      color: isSelected ? Colors.white : color,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : scheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}