import 'package:commons/commons.dart';

import '../model/user.dart';

abstract interface class IAuthRepository {
  AsyncResult<User> signInWithGoogle();

  AsyncResult<void> signOut();

  AsyncResult<User?> getCurrentUser();

  Stream<User?> observeAuthState();

  Future<String?> getIdToken();
}
