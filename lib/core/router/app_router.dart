// app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/projects/presentation/pages/projects_page.dart';
import '../../features/board/presentation/pages/board_page.dart';
import '../../features/task/presentation/pages/task_detail_page.dart';
import '../widgets/splash_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  
  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isAuthenticated = session != null;
      final isOnAuthPage = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isOnSplash = state.matchedLocation == '/splash';
      
      // Show splash screen first
      if (isOnSplash) return null;
      
      // Redirect logic
      if (!isAuthenticated) {
        // Not logged in, go to login unless already on auth page
        return isOnAuthPage ? null : '/login';
      }
      
      // Logged in
      if (isOnAuthPage) {
        // On login/register but already authenticated, go to projects
        return '/projects';
      }
      
      // Allow navigation to other pages
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/projects',
        builder: (context, state) => const ProjectsPage(),
      ),
      GoRoute(
        path: '/board/:projectId',
        builder: (context, state) => BoardPage(
          projectId: state.pathParameters['projectId']!,
          projectName: state.extra as String? ?? 'Board',
        ),
      ),
      GoRoute(
        path: '/task/:taskId',
        builder: (context, state) => TaskDetailPage(
          taskId: state.pathParameters['taskId']!,
        ),
      ),
    ],
  );
}