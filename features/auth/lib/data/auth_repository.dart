import 'package:commons/commons.dart';
import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:injectable/injectable.dart';

import 'package:auth/data/datasource/firebase/firebase_auth_data_source.dart';
import 'package:auth/domain/model/user.dart';
import 'package:auth/domain/repository/i_auth_repository.dart';

@Injectable(as: IAuthRepository)
class AuthRepository implements IAuthRepository {
  AuthRepository(this._dataSource);

  final FirebaseAuthDataSource _dataSource;

  @override
  AsyncResult<User> signInWithGoogle() async {
    try {
      final user = await _dataSource.signInWithGoogle();
      return Result.ok(user);
    } on SignInCancelledException {
      return Result.error(const OperationCancelledException());
    } on FirebaseAuthException catch (error) {
      return Result.error(_mapFirebaseAuthError(error));
    } catch (_) {
      return Result.error(
        const FirebaseDataException('Erro ao entrar com Google'),
      );
    }
  }

  @override
  AsyncResult<void> signOut() async {
    try {
      await _dataSource.signOut();
      return const Result.ok(null);
    } catch (_) {
      return Result.error(const FirebaseDataException('Erro ao sair'));
    }
  }

  @override
  AsyncResult<User?> getCurrentUser() async {
    try {
      return Result.ok(_dataSource.getCurrentUser());
    } catch (_) {
      return Result.error(const FirebaseDataException('Erro ao obter usuário'));
    }
  }

  @override
  Stream<User?> observeAuthState() => _dataSource.observeAuthState();

  @override
  Future<String?> getIdToken() => _dataSource.getIdToken();
}

@Injectable(as: ITokenGetter)
class AuthTokenGetter implements ITokenGetter {
  AuthTokenGetter(this._repository);

  final IAuthRepository _repository;

  @override
  Future<String?> getIdToken() => _repository.getIdToken();
}

Exception _mapFirebaseAuthError(FirebaseAuthException error) {
  switch (error.code) {
    case 'network-request-failed':
      return const ConnectionException();
    case 'user-disabled':
    case 'user-not-found':
      return const UnauthorizedException();
    default:
      return InvalidCredentialsException(
        error.message ?? 'Erro de autenticação',
      );
  }
}
