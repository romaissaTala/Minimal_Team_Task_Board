import 'package:equatable/equatable.dart';

class PresenceMember extends Equatable {
  final String userId;
  final String username;
  final String? avatarUrl;
  final String action; // 'typing', 'viewing', 'online'
  final String? taskId;
  final String? projectId;
  final DateTime updatedAt;

  const PresenceMember({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.action,
    this.taskId,
    this.projectId,
    required this.updatedAt,
  });

  bool get isTyping => action == 'typing';
  bool get isOnline => action == 'online' || action == 'viewing';

  @override
  List<Object?> get props => [userId, action, taskId];
}