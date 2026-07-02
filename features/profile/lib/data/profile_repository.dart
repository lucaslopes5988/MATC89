import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:commons/commons.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:injectable/injectable.dart';

import '../domain/model/gender_identity.dart';
import '../domain/model/user_profile.dart';
import '../domain/repository/i_profile_repository.dart';
import 'datasource/firebase/profile_firestore_data_source.dart';
import 'mapper/user_profile_mapper.dart';

@Injectable(as: IProfileRepository)
class ProfileRepository implements IProfileRepository {
  ProfileRepository(this._dataSource);

  final ProfileFirestoreDataSource _dataSource;

  @override
  AsyncResult<UserProfile> getProfile(String userId) async {
    try {
      final record = await _dataSource.getProfile(userId);
      return Result.ok(record.dto.toDomain(id: record.id));
    } on FirebaseException catch (error) {
      return Result.error(_mapFirebaseError(error));
    } catch (_) {
      return Result.error(
        const FirebaseDataException('Erro ao carregar perfil'),
      );
    }
  }

  @override
  AsyncResult<UserProfile> updateGenderIdentity({
    required String userId,
    required GenderIdentity? genderIdentity,
  }) async {
    try {
      final record = await _dataSource.updateGenderIdentity(
        userId: userId,
        genderIdentity: genderIdentity?.name,
      );
      return Result.ok(record.dto.toDomain(id: record.id));
    } on FirebaseException catch (error) {
      return Result.error(_mapFirebaseError(error));
    } catch (_) {
      return Result.error(
        const FirebaseDataException('Erro ao atualizar perfil'),
      );
    }
  }
}

Exception _mapFirebaseError(FirebaseException error) {
  if (error.code == 'unavailable' || error.code == 'network-request-failed') {
    return const ConnectionException();
  }
  return FirebaseDataException(error.message ?? 'Erro no Firestore');
}
