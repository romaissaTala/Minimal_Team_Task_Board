import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheck);
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
    on<LogoutRequested>(_onLogout);
  }

  void _onAuthCheck(AuthCheckRequested event, Emitter<AuthState> emit) {
    // GoRouter redirect handles navigation
    // We just emit unauthenticated if no user
    emit(AuthUnauthenticated());
  }

  Future<void> _onLogin(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await loginUseCase(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(_parseError(e)));
    }
  }

  Future<void> _onRegister(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await registerUseCase(
        email: event.email,
        password: event.password,
        username: event.username,
      );

      emit(AuthEmailSent("Check your email to confirm your account"));
    } catch (e) {
      emit(AuthError(_parseError(e)));
    }
  }
// auth_bloc.dart - Update the logout handler
Future<void> _onLogout(
  LogoutRequested event,
  Emitter<AuthState> emit,
) async {
  try {
    await logoutUseCase();
    emit(AuthUnauthenticated());
  } catch (e) {
    // Even if there's an error, we still want to clear local state
    emit(AuthUnauthenticated());
  }
}
  String _parseError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('invalid login')) return 'Invalid email or password';
    if (msg.contains('already registered')) return 'Email already in use';
    if (msg.contains('password'))
      return 'Password must be at least 6 characters';
    return 'Something went wrong. Please try again.';
  }
}
