import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.username,
    super.avatarUrl,
    super.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String email) {
    return UserModel(
      id: json['id'] as String,
      email: email,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String?,
      status: json['status'] as String? ?? 'online',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'avatar_url': avatarUrl,
    'status': status,
  };
}