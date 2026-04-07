import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/project_model.dart';

abstract class ProjectRemoteDataSource {
  Future<List<ProjectModel>> getProjects();
  Future<ProjectModel> createProject({
    required String name,
    String? description,
    String? color,
  });
  Future<void> deleteProject(String projectId);
}

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final SupabaseClient _client;
  ProjectRemoteDataSourceImpl(this._client);

  @override
  Future<List<ProjectModel>> getProjects() async {
    final userId = _client.auth.currentUser!.id;

    // Get projects where user is owner or member
    final owned = await _client
        .from('projects')
        .select()
        .eq('owner_id', userId)
        .order('created_at', ascending: false);

    final memberOf = await _client
        .from('project_members')
        .select('projects(*)')
        .eq('user_id', userId);

    final allProjects = <ProjectModel>[];

    for (final p in owned) {
      allProjects.add(ProjectModel.fromJson(p));
    }

    for (final m in memberOf) {
      final proj = m['projects'];
      if (proj != null && proj['owner_id'] != userId) {
        allProjects.add(ProjectModel.fromJson(proj));
      }
    }

    return allProjects;
  }

  @override
  Future<ProjectModel> createProject({
    required String name,
    String? description,
    String? color,
  }) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) throw Exception('No authenticated user');

    // First, ensure profile exists
    final profile = await _client
        .from('profiles')
        .select()
        .eq('id', currentUser.id)
        .maybeSingle();

    if (profile == null) {
      await _client.from('profiles').insert({
        'id': currentUser.id,
        'username': currentUser.email?.split('@').first ?? 'user',
        'status': 'online',
      });
    }

    // Create the project
    final response = await _client
        .from('projects')
        .insert({
          'name': name,
          'description': description,
          'owner_id': currentUser.id,
          'color': color ?? '#6366F1',
        })
        .select()
        .single();

    final projectId = response['id'] as String;

    // Add the owner as a member
    await _client.from('project_members').insert({
      'project_id': projectId,
      'user_id': currentUser.id,
      'role': 'owner',
    });

    // Create default columns for the project
    await _createDefaultColumns(projectId);

    return ProjectModel.fromJson(response);
  }

  Future<void> _createDefaultColumns(String projectId) async {
    const defaultColumns = [
      {'name': 'To Do', 'order_index': 0, 'color': '#EF4444'},
      {'name': 'In Progress', 'order_index': 1, 'color': '#F59E0B'},
      {'name': 'Done', 'order_index': 2, 'color': '#10B981'},
    ];

    for (final column in defaultColumns) {
      await _client.from('columns').insert({
        'project_id': projectId,
        'name': column['name'],
        'order_index': column['order_index'],
        'color': column['color'],
      });
    }
  }

  @override
  Future<void> deleteProject(String projectId) async {
    await _client.from('projects').delete().eq('id', projectId);
  }
}