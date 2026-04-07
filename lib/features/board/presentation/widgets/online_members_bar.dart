import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../presence/data/datasources/presence_service.dart';
import '../../../presence/domain/entities/presence_entity.dart';

/// Shows a row of member avatars in the board app bar.
/// Green dot = currently online/viewing this board.
class OnlineMembersBar extends StatefulWidget {
  final String projectId;
  const OnlineMembersBar({super.key, required this.projectId});

  @override
  State<OnlineMembersBar> createState() => _OnlineMembarsBarState();
}

class _OnlineMembarsBarState extends State<OnlineMembersBar> {
  List<PresenceMember> _members = [];

  @override
  void initState() {
    super.initState();
    // Announce that current user is viewing this board
    sl<PresenceService>().setViewing(projectId: widget.projectId);

    // Watch who else is online
    sl<PresenceService>()
        .watchOnlineInProject(widget.projectId)
        .listen((members) {
      if (mounted) setState(() => _members = members);
    });
  }

  @override
  void dispose() {
    sl<PresenceService>().clearPresence(projectId: widget.projectId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_members.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Show up to 4 avatars, then "+N more"
          ..._members.take(4).toList().asMap().entries.map((entry) {
            return _buildAvatar(entry.value, entry.key);
          }),
          if (_members.length > 4)
            Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(left: -8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '+${_members.length - 4}',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(PresenceMember member, int index) {
    return Container(
      width: 30,
      height: 30,
      margin: EdgeInsets.only(left: index == 0 ? 0 : -8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // Avatar circle
          CircleAvatar(
            radius: 13,
            backgroundColor: AppTheme.primary.withOpacity(0.2),
            backgroundImage: member.avatarUrl != null
                ? NetworkImage(member.avatarUrl!)
                : null,
            child: member.avatarUrl == null
                ? Text(
                    member.username[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  )
                : null,
          ),
          // Green online dot
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: AppTheme.secondary, // green
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}