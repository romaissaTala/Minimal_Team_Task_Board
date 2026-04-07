import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String username;
  final String? avatarUrl;
  final String status;

  const UserEntity({
    required this.id,
    required this.email,
    required this.username,
    this.avatarUrl,
    this.status = 'online',
  });

  @override
  List<Object?> get props => [id, email, username, avatarUrl, status];
}