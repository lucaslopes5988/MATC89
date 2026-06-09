import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

import 'package:auth/data/auth_debug_log.dart';
import 'package:auth/domain/model/user.dart';

@injectable
class FirebaseAuthDataSource {
  FirebaseAuthDataSource(this._firebaseAuth);

  final firebase_auth.FirebaseAuth _firebaseAuth;

  Stream<User?> observeAuthState() {
    return _firebaseAuth.authStateChanges().map(_mapFirebaseUser);
  }

  User? getCurrentUser() => _mapFirebaseUser(_firebaseAuth.currentUser);

  Future<User> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        logAuthDebugMessage('signInWithGoogle starting (web popup)');
        final provider = firebase_auth.GoogleAuthProvider();
        final userCredential = await _firebaseAuth.signInWithPopup(provider);
        return _requireUser(userCredential.user);
      }

      logAuthDebugMessage('signInWithGoogle starting (native GoogleSignIn)');
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw const SignInCancelledException();
      }

      logAuthDebugMessage('Google account selected: ${googleUser.email}');
      final googleAuth = await googleUser.authentication;
      logAuthDebugMessage(
        'Google tokens received '
        '(accessToken=${googleAuth.accessToken != null}, '
        'idToken=${googleAuth.idToken != null})',
      );

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      return _requireUser(userCredential.user);
    } catch (error, stackTrace) {
      logAuthDebug('signInWithGoogle failed in data source', error, stackTrace);
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (kIsWeb) {
      await _firebaseAuth.signOut();
      return;
    }

    await Future.wait([_firebaseAuth.signOut(), GoogleSignIn().signOut()]);
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

  User _requireUser(firebase_auth.User? firebaseUser) {
    final user = _mapFirebaseUser(firebaseUser);
    if (user == null) {
      throw firebase_auth.FirebaseAuthException(code: 'user-not-found');
    }

    return user;
  }
}

class SignInCancelledException implements Exception {
  const SignInCancelledException();
}
