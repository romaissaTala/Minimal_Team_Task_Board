import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/presence_entity.dart';


/// PresenceService handles all real-time presence features:
/// - Typing indicators: who is typing in which task
/// - Online status: who is currently in which project
/// 
/// How it works:
/// 1. User starts typing → we upsert a row in `presence` table with action='typing'
/// 2. After 3 seconds of no typing → we delete/update the row
/// 3. All other users have a Supabase Realtime subscription on `presence`
/// 4. When the table changes, they get the updated list of who is typing
class PresenceService {
  final SupabaseClient _client;
  Timer? _typingTimer;
  RealtimeChannel? _presenceChannel;

  PresenceService(this._client);

  String get _currentUserId => _client.auth.currentUser!.id;

  /// Call this whenever the user types something in a comment field.
  /// It sets a 3-second debounce — after 3s of silence, typing indicator disappears.
  Future<void> setTyping({
    required String taskId,
    required String projectId,
  }) async {
    // Cancel previous timer
    _typingTimer?.cancel();

    // Upsert typing presence
    await _client.from('presence').upsert({
      'user_id': _currentUserId,
      'task_id': taskId,
      'project_id': projectId,
      'action': 'typing',
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,task_id');

    // After 3 seconds without typing, clear the indicator
    _typingTimer = Timer(const Duration(seconds: 3), () {
      _clearTyping(taskId: taskId);
    });
  }

  Future<void> _clearTyping({required String taskId}) async {
    await _client
        .from('presence')
        .delete()
        .eq('user_id', _currentUserId)
        .eq('task_id', taskId);
  }

  /// Set user as "viewing" a project (online indicator in app bar)
  Future<void> setViewing({required String projectId}) async {
    await _client.from('presence').upsert({
      'user_id': _currentUserId,
      'project_id': projectId,
      'action': 'online',
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,project_id');
  }

  Future<void> clearPresence({String? projectId}) async {
    _typingTimer?.cancel();
    final q = _client.from('presence').delete().eq('user_id', _currentUserId);
    if (projectId != null) {
      await q.eq('project_id', projectId);
    } else {
      await q;
    }
  }

  /// Stream of who is typing in a specific task
  Stream<List<PresenceMember>> watchTypingInTask(String taskId) {
    return _client
        .from('presence')
        .stream(primaryKey: ['id'])
        .eq('task_id', taskId)
        .map((rows) {
          final currentUserId = _currentUserId;
          return rows
              .where((r) =>
                  r['action'] == 'typing' &&
                  r['user_id'] != currentUserId)
              .map((r) => PresenceMember(
                    userId: r['user_id'] as String,
                    username: r['username'] as String? ?? 'Someone',
                    action: 'typing',
                    taskId: taskId,
                    updatedAt: DateTime.parse(r['updated_at'] as String),
                  ))
              .toList();
        });
  }

  /// Stream of who is online in a project (for the app bar avatars)
  Stream<List<PresenceMember>> watchOnlineInProject(String projectId) {
    return _client
        .from('presence')
        .stream(primaryKey: ['id'])
        .eq('project_id', projectId)
        .map((rows) {
          return rows
              .map((r) => PresenceMember(
                    userId: r['user_id'] as String,
                    username: r['username'] as String? ?? '?',
                    avatarUrl: r['avatar_url'] as String?,
                    action: r['action'] as String,
                    projectId: projectId,
                    updatedAt: DateTime.parse(r['updated_at'] as String),
                  ))
              .toList();
        });
  }

  void dispose() {
    _typingTimer?.cancel();
    _presenceChannel?.unsubscribe();
  }
}