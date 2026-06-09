import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

import 'package:auth/domain/model/user.dart';

@injectable
class FirebaseAuthDataSource {
  FirebaseAuthDataSource(this._firebaseAuth, this._googleSignIn);

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  Stream<User?> observeAuthState() {
    return _firebaseAuth.authStateChanges().map(_mapFirebaseUser);
  }

  User? getCurrentUser() => _mapFirebaseUser(_firebaseAuth.currentUser);

  Future<User> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw const SignInCancelledException();
    }

    final googleAuth = await googleUser.authentication;
    final credential = firebase_auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);

    final user = _mapFirebaseUser(userCredential.user);
    if (user == null) {
      throw firebase_auth.FirebaseAuthException(code: 'user-not-found');
    }

    return user;
  }

  Future<void> signOut() async {
    await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
  }

  Future<String?> getIdToken() async {
    return _firebaseAuth.currentUser?.getIdToken();
  }

  User? _mapFirebaseUser(firebase_auth.User? firebaseUser) {
    if (firebaseUser == null) {
      return null;
    }

    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
    );
  }
}

class SignInCancelledException implements Exception {
  const SignInCancelledException();
}
