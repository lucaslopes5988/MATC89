import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../dto/db/user_profile_db_dto.dart';
import '../endpoint/endpoint.dart';

@injectable
class ProfileFirestoreDataSource {
  ProfileFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(ProfileEndpoints.usersCollection);

  Future<({UserProfileDbDto dto, String id})> getProfile(
    String userId,
  ) async {
    final doc = await _collection.doc(userId).get();
    if (!doc.exists || doc.data() == null) {
      return (dto: const UserProfileDbDto(), id: userId);
    }

    return (dto: UserProfileDbDto.fromFirestore(doc.data()!), id: doc.id);
  }

  Future<({UserProfileDbDto dto, String id})> updateGenderIdentity({
    required String userId,
    required String? genderIdentity,
  }) async {
    final docRef = _collection.doc(userId);
    final data = {
      'genderIdentity': genderIdentity,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await docRef.set(data, SetOptions(merge: true));

    final updated = await docRef.get();
    return (
      dto: UserProfileDbDto.fromFirestore(updated.data() ?? {}),
      id: userId,
    );
  }
}
