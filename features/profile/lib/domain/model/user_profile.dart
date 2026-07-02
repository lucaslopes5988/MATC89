import 'package:equatable/equatable.dart';

import 'gender_identity.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    this.genderIdentity,
    this.updatedAt,
  });

  final String id;
  final GenderIdentity? genderIdentity;
  final DateTime? updatedAt;

  bool get isWoman => genderIdentity == GenderIdentity.woman;

  @override
  List<Object?> get props => [id, genderIdentity, updatedAt];
}
