import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/project_entity.dart';

class ProjectCard extends StatelessWidget {
  final ProjectEntity project;
  final int index;
  final VoidCallback onTap;

  const ProjectCard({
    super.key,
    required this.project,
    required this.index,
    required this.onTap,
  });

  Color get _color {
    try {
      return Color(
        int.parse(project.color.replaceFirst('#', '0xFF')),
      );
    } catch (_) {
      return const Color(0xFF6366F1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _color.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Top color bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  color: _color,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.dashboard_rounded,
                      color: _color,
                      size: 20,
                    ),
                  ),

                  const Spacer(),

                  // Name
                  Text(
                    project.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (project.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      project.description!,
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurface.withOpacity(0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      )
      .animate()
      .fadeIn(delay: Duration(milliseconds: 80 * index), duration: 400.ms)
      .slideY(begin: 0.15, end: 0),
    );
  }
}