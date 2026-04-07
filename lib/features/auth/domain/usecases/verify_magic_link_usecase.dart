import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyMagicLinkUseCase {
  final AuthRepository repository;
  
  VerifyMagicLinkUseCase(this.repository);

  Future<UserEntity> call({
    required String email,
    required String token,
  }) {
    return repository.verifyMagicLink(email: email, token: token);
  }
}