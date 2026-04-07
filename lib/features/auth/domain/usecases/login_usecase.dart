import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';


class LoginUseCase {
  final AuthRepository repository;
  
  LoginUseCase(this.repository);

  Future<UserEntity> call({
    required String email,
    required String password,
  }) => repository.login(email: email, password: password);
  
  // Add this method
  UserEntity? getCurrentUser() => repository.getCurrentUser();
}