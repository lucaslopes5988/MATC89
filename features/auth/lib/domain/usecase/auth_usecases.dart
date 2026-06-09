import 'package:commons/commons.dart';
import 'package:injectable/injectable.dart';

import '../model/user.dart';
import '../repository/i_auth_repository.dart';

@injectable
class SignInWithGoogleUseCase {
  const SignInWithGoogleUseCase(this._repository);

  final IAuthRepository _repository;

  AsyncResult<User> invoke() => _repository.signInWithGoogle();
}

@injectable
class SignOutUseCase {
  const SignOutUseCase(this._repository);

  final IAuthRepository _repository;

  AsyncResult<void> invoke() => _repository.signOut();
}

@injectable
class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._repository);

  final IAuthRepository _repository;

  AsyncResult<User?> invoke() => _repository.getCurrentUser();
}

@injectable
class ObserveAuthStateUseCase {
  const ObserveAuthStateUseCase(this._repository);

  final IAuthRepository _repository;

  Stream<User?> invoke() => _repository.observeAuthState();
}
