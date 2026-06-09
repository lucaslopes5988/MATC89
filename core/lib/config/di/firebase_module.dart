import 'package:firebase_core/firebase_core.dart';
import 'package:injectable/injectable.dart';

import 'package:core/firebase/firebase_options.dart';

@module
abstract class FirebaseModule {
  @preResolve
  Future<FirebaseApp> provideFirebaseApp() async {
    if (Firebase.apps.isNotEmpty) {
      return Firebase.app();
    }

    return Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
