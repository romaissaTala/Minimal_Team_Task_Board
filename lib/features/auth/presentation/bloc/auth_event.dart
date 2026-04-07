import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  
  const LoginRequested({required this.email, required this.password});
  
  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String username;
  
  const RegisterRequested({
    required this.email,
    required this.password,
    required this.username,
  });
  
  @override
  List<Object?> get props => [email, password, username];
}

class LogoutRequested extends AuthEvent {}

// Add these new events
class SendMagicLinkRequested extends AuthEvent {
  final String email;
  
  const SendMagicLinkRequested({required this.email});
  
  @override
  List<Object?> get props => [email];
}

class VerifyMagicLinkRequested extends AuthEvent {
  final String email;
  final String token;
  
  const VerifyMagicLinkRequested({
    required this.email,
    required this.token,
  });
  
  @override
  List<Object?> get props => [email, token];
}