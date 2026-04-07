import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    final session = Supabase.instance.client.auth.currentSession;
    context.go(session != null ? '/projects' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.dashboard_rounded,
                size: 44,
                color: AppTheme.primary,
              ),
            )
            .animate()
            .scale(duration: 600.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            const Text(
              'TaskBoard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
                letterSpacing: 0.5,
              ),
            )
            .animate()
            .fadeIn(delay: 300.ms, duration: 500.ms)
            .slideY(begin: 0.3, end: 0),
            const SizedBox(height: 8),
            const Text(
              'Collaborate in real-time',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            )
            .animate()
            .fadeIn(delay: 500.ms, duration: 500.ms),
          ],
        ),
      ),
    );
  }
}