import '../repositories/auth_repository.dart';

class SendMagicLinkUseCase {
  final AuthRepository repository;
  
  SendMagicLinkUseCase(this.repository);

  Future<void> call({required String email}) {
    return repository.sendMagicLink(email: email);
  }
}