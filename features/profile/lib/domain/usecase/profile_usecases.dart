import 'package:commons/commons.dart';
import 'package:injectable/injectable.dart';

import '../model/gender_identity.dart';
import '../model/user_profile.dart';
import '../repository/i_profile_repository.dart';

@injectable
class GetProfileUseCase {
  const GetProfileUseCase(this._repository);

  final IProfileRepository _repository;

  AsyncResult<UserProfile> invoke(String userId) {
    return _repository.getProfile(userId);
  }
}

@injectable
class UpdateGenderIdentityUseCase {
  const UpdateGenderIdentityUseCase(this._repository);

  final IProfileRepository _repository;

  AsyncResult<UserProfile> invoke({
    required String userId,
    required GenderIdentity? genderIdentity,
  }) {
    return _repository.updateGenderIdentity(
      userId: userId,
      genderIdentity: genderIdentity,
    );
  }
}
