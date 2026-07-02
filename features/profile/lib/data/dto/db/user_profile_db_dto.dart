import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileDbDto {
  const UserProfileDbDto({
    this.genderIdentity,
    this.updatedAt,
  });

  final String? genderIdentity;
  final Timestamp? updatedAt;

  factory UserProfileDbDto.fromFirestore(Map<String, dynamic> data) {
    return UserProfileDbDto(
      genderIdentity: data['genderIdentity'] as String?,
      updatedAt: data['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'genderIdentity': genderIdentity,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
