import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../presence/data/datasources/presence_service.dart';
import '../../../presence/domain/entities/presence_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';

class TaskDetailPage extends StatelessWidget {
  final String taskId;
  const TaskDetailPage({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TaskBloc>()..add(LoadTask(taskId)),
      child: _TaskDetailView(taskId: taskId),
    );
  }
}

class _TaskDetailView extends StatefulWidget {
  final String taskId;
  const _TaskDetailView({required this.taskId});

  @override
  State<_TaskDetailView> createState() => _TaskDetailViewState();
}

class _TaskDetailViewState extends State<_TaskDetailView> {
 final _commentCtrl = TextEditingController();
  bool _isTyping = false;
  StreamSubscription? _typingSubscription;
  List<PresenceMember> _typingMembers = [];

  @override
  void initState() {
    super.initState();
    _startWatchingTyping();
  }

  void _startWatchingTyping() {
    _typingSubscription = sl<PresenceService>()
        .watchTypingInTask(widget.taskId)
        .listen((members) {
      if (mounted) {
        setState(() => _typingMembers = members);
      }
    });
  }

  @override
  void dispose() {
    _typingSubscription?.cancel();
    sl<PresenceService>().clearPresence();
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHighest,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Task detail'),
        backgroundColor: scheme.surface,
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TaskError) {
            return Center(child: Text(state.message));
          }

          final task = state is TaskLoaded
              ? state.task
              : state is TaskUpdating
                  ? state.task
                  : null;

          if (task == null) return const SizedBox.shrink();

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTaskHeader(task, scheme),
                      const SizedBox(height: 16),
                      _buildMetadata(task, scheme),
                      const SizedBox(height: 24),
                      _buildCommentsSection(task, scheme),
                    ],
                  ),
                ),
              ),
              _buildCommentInput(scheme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTaskHeader(TaskDetailEntity task, ColorScheme scheme) {
    Color priorityColor = switch (task.priority) {
      'high' => AppTheme.priorityHigh,
      'low' => AppTheme.priorityLow,
      _ => AppTheme.priorityMedium,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  task.priority.toUpperCase(),
                  style: TextStyle(
                    color: priorityColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  task.columnName,
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            task.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (task.description != null && task.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              task.description!,
              style: TextStyle(
                fontSize: 14,
                color: scheme.onSurface.withOpacity(0.6),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildMetadata(TaskDetailEntity task, ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (task.assigneeUsername != null)
            _buildMetaRow(
              icon: Icons.person_outline_rounded,
              label: 'Assignee',
              value: task.assigneeUsername!,
              scheme: scheme,
            ),
          if (task.dueDate != null) ...[
            const Divider(height: 24),
            _buildMetaRow(
              icon: Icons.calendar_today_rounded,
              label: 'Due date',
              value: DateFormat('MMM dd, yyyy').format(task.dueDate!),
              scheme: scheme,
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 300.ms);
  }

  Widget _buildMetaRow({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme scheme,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: scheme.onSurface.withOpacity(0.4)),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: scheme.onSurface.withOpacity(0.5),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsSection(TaskDetailEntity task, ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comments (${task.comments.length})',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (task.comments.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No comments yet. Be the first!',
                style: TextStyle(color: scheme.onSurface.withOpacity(0.4)),
              ),
            ),
          ),
        ...task.comments.asMap().entries.map((entry) {
          return _buildComment(entry.value, entry.key, scheme);
        }),
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 300.ms);
  }

  Widget _buildComment(CommentEntity comment, int index, ColorScheme scheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    comment.username[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                comment.username,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                _timeAgo(comment.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: scheme.onSurface.withOpacity(0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.content,
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
        ],
      ),
    ).animate().fadeIn(
          delay: Duration(milliseconds: 50 * index),
          duration: 300.ms,
        );
  }

  Widget _buildTypingIndicator() {
    if (_typingMembers.isEmpty) return const SizedBox.shrink();

    final names = _typingMembers.map((m) => m.username).join(', ');
    final verb = _typingMembers.length == 1 ? 'is' : 'are';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          _TypingDots(),
          const SizedBox(width: 8),
          Text(
            '$names $verb typing...',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.primary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(ColorScheme scheme) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outline.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentCtrl,
              onChanged: (v) => setState(() => _isTyping = v.isNotEmpty),
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                suffixIcon: _isTyping
                    ? null
                    : Icon(
                        Icons.emoji_emotions_outlined,
                        color: scheme.onSurface.withOpacity(0.3),
                      ),
              ),
              minLines: 1,
              maxLines: 4,
            ),
          ),
          const SizedBox(width: 8),
          AnimatedScale(
            scale: _isTyping ? 1.0 : 0.8,
            duration: const Duration(milliseconds: 200),
            child: AnimatedOpacity(
              opacity: _isTyping ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _isTyping ? AppTheme.primary : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: _isTyping ? _submitComment : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitComment() {
    final content = _commentCtrl.text.trim();
    if (content.isEmpty) return;
    context.read<TaskBloc>().add(AddComment(
          taskId: widget.taskId,
          content: content,
        ));
    _commentCtrl.clear();
    setState(() => _isTyping = false);
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

/// Animated three-dot typing indicator
class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            // Each dot has a staggered phase
            final phase = ((_controller.value * 3) - i).clamp(0.0, 1.0);
            final scale =
                0.6 + (0.4 * (phase < 0.5 ? phase * 2 : (1 - phase) * 2));
            return Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 3),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.4 + 0.6 * scale),
                shape: BoxShape.circle,
              ),
              transform: Matrix4.identity()
                ..translate(0.0, -3.0 * (scale - 0.6) / 0.4),
            );
          }),
        );
      },
    );
  }
}
