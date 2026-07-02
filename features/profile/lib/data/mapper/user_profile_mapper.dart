import '../../domain/model/gender_identity.dart';
import '../../domain/model/user_profile.dart';
import '../dto/db/user_profile_db_dto.dart';

extension UserProfileDbDtoMapper on UserProfileDbDto {
  UserProfile toDomain({required String id}) {
    return UserProfile(
      id: id,
      genderIdentity: _parseGenderIdentity(genderIdentity),
      updatedAt: updatedAt?.toDate(),
    );
  }
}

GenderIdentity? _parseGenderIdentity(String? value) {
  if (value == null) return null;
  return GenderIdentity.values.where((e) => e.name == value).firstOrNull;
}

extension UserProfileDomainMapper on UserProfile {
  UserProfileDbDto toDbDto() {
    return UserProfileDbDto(
      genderIdentity: genderIdentity?.name,
    );
  }
}
