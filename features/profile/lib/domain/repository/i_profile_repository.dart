import 'package:commons/commons.dart';

import '../model/gender_identity.dart';
import '../model/user_profile.dart';

abstract interface class IProfileRepository {
  AsyncResult<UserProfile> getProfile(String userId);

  AsyncResult<UserProfile> updateGenderIdentity({
    required String userId,
    required GenderIdentity? genderIdentity,
  });
}
