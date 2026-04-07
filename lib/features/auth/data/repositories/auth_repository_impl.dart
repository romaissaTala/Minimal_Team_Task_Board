import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  AuthRepositoryImpl(this._dataSource);

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) => _dataSource.login(email: email, password: password);

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String username,
  }) => _dataSource.register(
    email: email,
    password: password,
    username: username,
  );

  @override
  Future<void> logout() => _dataSource.logout();

  @override
  UserEntity? getCurrentUser() => _dataSource.getCurrentUser();
}