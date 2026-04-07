import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:minimal_team_task_board/features/auth/domain/entities/user_entity.dart';
import 'package:minimal_team_task_board/features/auth/domain/usecases/login_usecase.dart';
import 'package:minimal_team_task_board/features/auth/domain/usecases/register_usecase.dart';
import 'package:minimal_team_task_board/features/auth/domain/usecases/logout_usecase.dart';
import 'package:minimal_team_task_board/features/auth/domain/usecases/send_magic_link_usecase.dart';
import 'package:minimal_team_task_board/features/auth/domain/usecases/verify_magic_link_usecase.dart';
import 'package:minimal_team_task_board/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:minimal_team_task_board/features/auth/presentation/bloc/auth_event.dart';
import 'package:minimal_team_task_board/features/auth/presentation/bloc/auth_state.dart';

// Mocks
class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockSendMagicLinkUseCase extends Mock implements SendMagicLinkUseCase {}

class MockVerifyMagicLinkUseCase extends Mock
    implements VerifyMagicLinkUseCase {}

void main() {
  late AuthBloc authBloc;
  late MockLoginUseCase loginUseCase;
  late MockRegisterUseCase registerUseCase;
  late MockLogoutUseCase logoutUseCase;
  late MockSendMagicLinkUseCase sendMagicLinkUseCase;
  late MockVerifyMagicLinkUseCase verifyMagicLinkUseCase;

  const testUser = UserEntity(
    id: 'test-id-123',
    email: 'test@example.com',
    username: 'testuser',
  );

  setUp(() {
    loginUseCase = MockLoginUseCase();
    registerUseCase = MockRegisterUseCase();
    logoutUseCase = MockLogoutUseCase();
    sendMagicLinkUseCase = MockSendMagicLinkUseCase();
    verifyMagicLinkUseCase = MockVerifyMagicLinkUseCase();

    authBloc = AuthBloc(
      loginUseCase: loginUseCase,
      registerUseCase: registerUseCase,
      logoutUseCase: logoutUseCase,
      sendMagicLinkUseCase: sendMagicLinkUseCase,
      verifyMagicLinkUseCase: verifyMagicLinkUseCase,
    );
  });

  tearDown(() => authBloc.close());

  group('AuthBloc — LoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when login succeeds',
      build: () {
        when(() => loginUseCase(
              email: 'test@example.com',
              password: 'password123',
            )).thenAnswer((_) async => testUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(LoginRequested(
        email: 'test@example.com',
        password: 'password123',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>()
            .having((s) => s.user.email, 'email', 'test@example.com'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails',
      build: () {
        when(() => loginUseCase(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(Exception('Invalid login credentials'));
        return authBloc;
      },
      act: (bloc) => bloc.add(LoginRequested(
        email: 'wrong@email.com',
        password: 'wrongpass',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having(
            (s) => s.message, 'message', contains('Invalid email or password')),
      ],
    );
  });

  group('AuthBloc — SendMagicLinkRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthMagicLinkSent] when magic link sent successfully',
      build: () {
        when(() => sendMagicLinkUseCase(email: any(named: 'email')))
            .thenAnswer((_) async => Future.value());
        return authBloc;
      },
      act: (bloc) =>
          bloc.add(SendMagicLinkRequested(email: 'test@example.com')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthMagicLinkSent>()
            .having((s) => s.email, 'email', 'test@example.com'),
      ],
    );
  });

  group('AuthBloc — LogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated] when logout succeeds',
      build: () {
        when(() => logoutUseCase()).thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [isA<AuthUnauthenticated>()],
    );
  });
}
