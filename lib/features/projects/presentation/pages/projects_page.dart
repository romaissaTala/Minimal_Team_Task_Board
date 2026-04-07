import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/project_bloc.dart';
import '../bloc/project_event.dart';
import '../bloc/project_state.dart';
import '../widgets/project_card.dart';
import '../widgets/create_project_sheet.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProjectBloc>()..add(LoadProjects()),
      child: const _ProjectsView(),
    );
  }
}

class _ProjectsView extends StatelessWidget {
  const _ProjectsView();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHighest,
      appBar: AppBar(
        title: const Text('My workspace'),
        backgroundColor: scheme.surface,
        // projects_page.dart - Update the logout button
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              // Add loading state
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              try {
                context.read<AuthBloc>().add(LogoutRequested());
                // Wait a bit for logout to complete
                await Future.delayed(const Duration(milliseconds: 100));
                if (context.mounted) {
                  context.go('/login');
                }
              } catch (e) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('Logout failed: ${e.toString()}')),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSheet(context),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New project'),
      ),
      body: BlocBuilder<ProjectBloc, ProjectState>(
        builder: (context, state) {
          if (state is ProjectLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProjectError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: scheme.error),
                  const SizedBox(height: 12),
                  Text(state.message),
                  TextButton(
                    onPressed: () =>
                        context.read<ProjectBloc>().add(LoadProjects()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ProjectsLoaded && state.projects.isEmpty) {
            return _EmptyState(onCreateTap: () => _showCreateSheet(context));
          }

          if (state is ProjectsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProjectBloc>().add(LoadProjects());
              },
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: state.projects.length,
                itemBuilder: (context, index) {
                  return ProjectCard(
                    project: state.projects[index],
                    index: index,
                    onTap: () => context.push(
                      '/board/${state.projects[index].id}',
                      extra: state.projects[index].name,
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ProjectBloc>(),
        child: const CreateProjectSheet(),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateTap;
  const _EmptyState({required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.dashboard_outlined,
              size: 40,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No projects yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first project to get started',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onCreateTap,
            icon: const Icon(Icons.add),
            label: const Text('Create project'),
          ),
        ],
      )
          .animate()
          .fadeIn(duration: 500.ms)
          .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
    );
  }
}
