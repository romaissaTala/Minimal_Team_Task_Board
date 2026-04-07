import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  final String projectId;

  const TaskDetailPage(
      {super.key, required this.taskId, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TaskBloc>()..add(LoadTask(taskId)),
      child: _TaskDetailView(taskId: taskId, projectId: projectId),
    );
  }
}

class _TaskDetailView extends StatefulWidget {
  final String taskId;
  final String projectId;

  const _TaskDetailView({required this.taskId, required this.projectId});

  @override
  State<_TaskDetailView> createState() => _TaskDetailViewState();
}

class _TaskDetailViewState extends State<_TaskDetailView>
    with WidgetsBindingObserver {
  final _commentCtrl = TextEditingController();
  final _focusNode = FocusNode();
  bool _isTyping = false;
  StreamSubscription? _typingSubscription;
  List<PresenceMember> _typingMembers = [];
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startWatchingTyping();
    _setupTypingDetection();
  }

  void _setupTypingDetection() {
    _commentCtrl.addListener(() {
      final isCurrentlyTyping = _commentCtrl.text.isNotEmpty;
      if (isCurrentlyTyping != _isTyping) {
        setState(() => _isTyping = isCurrentlyTyping);
        if (isCurrentlyTyping) {
          _sendTypingIndicator();
        }
      }
    });
  }

  void _sendTypingIndicator() {
    sl<PresenceService>().setTyping(
      taskId: widget.taskId,
      projectId: widget.projectId,
    );
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
    _commentCtrl.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Scroll to bottom when keyboard appears
    // Added a small delay to allow Scaffold to finish its internal resize
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted && _scrollController.hasClients && _focusNode.hasFocus) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      // Ensure the Scaffold resizes when the keyboard opens
      resizeToAvoidBottomInset: true,
      backgroundColor: scheme.surfaceContainerHighest,
      appBar: _buildAppBar(scheme),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  if (state is TaskLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is TaskError) {
                    return _buildErrorView(state.message, scheme);
                  }

                  final task = state is TaskLoaded
                      ? state.task
                      : state is TaskUpdating
                          ? state.task
                          : null;

                  if (task == null) return const SizedBox.shrink();

                  return GestureDetector(
                    onTap: () => _focusNode.unfocus(),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTaskHeader(task, scheme),
                          const SizedBox(height: 16),
                          _buildMetadata(task, scheme),
                          const SizedBox(height: 24),
                          _buildCommentsSection(task, scheme),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // The input is now naturally pushed up by the Scaffold
            _buildCommentInput(scheme),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme scheme) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded),
        onPressed: () => context.pop(),
      ),
      title: const Text('Task Details'),
      backgroundColor: scheme.surface,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showTaskOptions(),
        ),
      ],
    );
  }

  Widget _buildErrorView(String message, ColorScheme scheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: scheme.error),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: scheme.onSurface)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                context.read<TaskBloc>().add(LoadTask(widget.taskId)),
            child: const Text('Retry'),
          ),
        ],
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      task.priority == 'high'
                          ? Icons.flag
                          : Icons.flag_outlined,
                      size: 14,
                      color: priorityColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      task.priority.toUpperCase(),
                      style: TextStyle(
                        color: priorityColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  task.columnName,
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            task.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          if (task.description != null && task.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                task.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: scheme.onSurface.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildMetadata(TaskDetailEntity task, ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (task.assigneeUsername != null)
            _buildMetaRow(
              icon: Icons.person_outline_rounded,
              label: 'Assignee',
              value: task.assigneeUsername!,
              scheme: scheme,
              onTap: () => _showAssigneeOptions(),
            ),
          if (task.dueDate != null) ...[
            if (task.assigneeUsername != null) const Divider(height: 24),
            _buildMetaRow(
              icon: Icons.calendar_today_rounded,
              label: 'Due date',
              value: DateFormat('MMM dd, yyyy').format(task.dueDate!),
              scheme: scheme,
              onTap: () => _showDatePicker(),
            ),
          ],
          const Divider(height: 24),
          _buildMetaRow(
            icon: Icons.edit_note,
            label: 'Edit details',
            value: 'Tap to edit',
            scheme: scheme,
            onTap: () => _showEditDialog(task),
            isEditable: true,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 300.ms);
  }

  Widget _buildMetaRow({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme scheme,
    VoidCallback? onTap,
    bool isEditable = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: scheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppTheme.primary),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: scheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isEditable ? FontWeight.w400 : FontWeight.w500,
                color: isEditable ? AppTheme.primary : scheme.onSurface,
              ),
            ),
            if (isEditable)
              Icon(Icons.chevron_right,
                  size: 20, color: scheme.onSurface.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection(TaskDetailEntity task, ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.comment_outlined, size: 20),
              const SizedBox(width: 8),
              Text(
                'Comments (${task.comments.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTypingIndicator(),
          if (task.comments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(Icons.chat_bubble_outline,
                        size: 48, color: scheme.onSurface.withOpacity(0.2)),
                    const SizedBox(height: 12),
                    Text(
                      'No comments yet',
                      style:
                          TextStyle(color: scheme.onSurface.withOpacity(0.4)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Be the first to comment',
                      style: TextStyle(
                        color: scheme.onSurface.withOpacity(0.3),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ...task.comments.asMap().entries.map((entry) {
            return _buildComment(entry.value, entry.key, scheme);
          }),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 300.ms);
  }

  Widget _buildComment(CommentEntity comment, int index, ColorScheme scheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.primary.withOpacity(0.1),
            child: Text(
              comment.username[0].toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _timeAgo(comment.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    comment.content,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TypingDots(),
          const SizedBox(width: 8),
          Text(
            '$names $verb typing...',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(ColorScheme scheme) {
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outline.withOpacity(0.1))),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints:
                    const BoxConstraints(minHeight: 40, maxHeight: 100),
                child: TextField(
                  controller: _commentCtrl,
                  focusNode: _focusNode,
                  onChanged: (v) => setState(() => _isTyping = v.isNotEmpty),
                  decoration: InputDecoration(
                    hintText: 'Write a comment...',
                    hintStyle:
                        TextStyle(color: scheme.onSurface.withOpacity(0.4)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide:
                          BorderSide(color: scheme.outline.withOpacity(0.2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide:
                          BorderSide(color: scheme.outline.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: AppTheme.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    isDense: true,
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submitComment(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: InkWell(
                onTap: _isTyping ? _submitComment : null,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _isTyping
                        ? AppTheme.primary
                        : scheme.onSurface.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.send_rounded,
                    size: 20,
                    color: _isTyping
                        ? Colors.white
                        : scheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ],
        ),
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

    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showTaskOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Task'),
              onTap: () {
                Navigator.pop(ctx);
                final state = context.read<TaskBloc>().state;
                if (state is TaskLoaded) _showEditDialog(state.task);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Task',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(TaskDetailEntity? task) {
    if (task == null) return;

    final titleCtrl = TextEditingController(text: task.title);
    final descCtrl = TextEditingController(text: task.description ?? '');
    String selectedPriority = task.priority;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                ],
                onChanged: (value) {
                  if (value != null) selectedPriority = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) return;

              context.read<TaskBloc>().add(UpdateTask(
                    taskId: widget.taskId,
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim().isEmpty
                        ? null
                        : descCtrl.text.trim(),
                    priority: selectedPriority,
                  ));

              Navigator.pop(ctx);
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Task updated')));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAssigneeOptions() {}
  void _showDatePicker() {}

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text(
            'Are you sure you want to delete this task? This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Deleting task...')));
              try {
                await Supabase.instance.client
                    .from('tasks')
                    .delete()
                    .eq('id', widget.taskId);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Task deleted successfully'),
                    backgroundColor: Colors.green,
                  ));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Error deleting task: $e'),
                    backgroundColor: Colors.red,
                  ));
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(date);
  }
}

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
      duration: const Duration(milliseconds: 1200),
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
            final delay = i * 0.2;
            final value = (_controller.value + delay) % 1.0;
            final scale = 0.5 + (value * 0.5);

            return Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 3),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.4 + (value * 0.6)),
                shape: BoxShape.circle,
              ),
              transform: Matrix4.identity()..scale(scale),
            );
          }),
        );
      },
    );
  }
}
