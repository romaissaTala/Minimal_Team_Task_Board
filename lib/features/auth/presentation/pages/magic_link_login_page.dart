import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class MagicLinkLoginPage extends StatefulWidget {
  const MagicLinkLoginPage({super.key});

  @override
  State<MagicLinkLoginPage> createState() => _MagicLinkLoginPageState();
}

class _MagicLinkLoginPageState extends State<MagicLinkLoginPage> {
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  bool _linkSent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthMagicLinkSent) {
            // Magic link sent successfully
            setState(() {
              _linkSent = true;
              _isLoading = false;
            });
          } else if (state is AuthAuthenticated) {
            // User authenticated, go to projects
            context.go('/projects');
          } else if (state is AuthError) {
            // Error occurred
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: scheme.error,
              ),
            );
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Logo
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.dashboard_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  )
                      .animate()
                      .scale(duration: 400.ms, curve: Curves.easeOutBack),

                  const SizedBox(height: 32),

                  Text(
                    _linkSent ? 'Check your email' : 'Welcome back',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 6),

                  Text(
                    _linkSent
                        ? 'Click the magic link in your email to sign in'
                        : 'Sign in with email (no password needed)',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurface.withOpacity(0.55),
                        ),
                  ).animate().fadeIn(delay: 150.ms),

                  const SizedBox(height: 36),

                  if (!_linkSent) ...[
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                        hintText: 'you@example.com',
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _sendMagicLink,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Send magic link'),
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.mark_email_read_rounded,
                            size: 48,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Magic link sent to:',
                            style: TextStyle(
                                color: scheme.onSurface.withOpacity(0.6)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _emailCtrl.text,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextButton(
                            onPressed: () => setState(() => _linkSent = false),
                            child: const Text('Use different email'),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Divider
                  if (!_linkSent)
                    Row(
                      children: [
                        Expanded(
                            child: Divider(
                                color: scheme.onSurface.withOpacity(0.2))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or',
                            style: TextStyle(
                                color: scheme.onSurface.withOpacity(0.4)),
                          ),
                        ),
                        Expanded(
                            child: Divider(
                                color: scheme.onSurface.withOpacity(0.2))),
                      ],
                    ).animate().fadeIn(delay: 350.ms),

                  if (!_linkSent)
                    Center(
                      child: TextButton(
                        onPressed: () => context.go('/login'),
                        child: Text(
                          'Sign in with password',
                          style: TextStyle(color: AppTheme.primary),
                        ),
                      ),
                    ).animate().fadeIn(delay: 400.ms),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                            color: scheme.onSurface.withOpacity(0.55)),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/register'),
                        child: Text(
                          'Create one',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 450.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendMagicLink() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ CORRECT: Add the event to the bloc
      context.read<AuthBloc>().add(SendMagicLinkRequested(email: email));

      // Wait a bit for the event to process
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _linkSent = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}
