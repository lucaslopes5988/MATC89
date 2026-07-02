import 'package:commons/commons.dart';
import 'package:injectable/injectable.dart';

import 'package:profile/domain/model/gender_identity.dart';
import 'package:profile/domain/usecase/profile_usecases.dart';
import 'profile_state.dart';

@injectable
class ProfileCubit extends SafeCubit<ProfileState> {
  ProfileCubit(
    this._getProfileUseCase,
    this._updateGenderIdentityUseCase,
  ) : super(const ProfileInitialState());

  final GetProfileUseCase _getProfileUseCase;
  final UpdateGenderIdentityUseCase _updateGenderIdentityUseCase;

  Future<void> load(String userId) async {
    emit(const ProfileLoadingState());

    final result = await _getProfileUseCase.invoke(userId);
    switch (result) {
      case Ok(value: final profile):
        emit(ProfileLoadedState(profile: profile));
      case Error(error: final error) when error is ConnectionException:
        emit(const ProfileErrorState(message: 'Sem conexão'));
      case Error():
        emit(const ProfileErrorState(message: 'Erro ao carregar perfil'));
    }
  }

  Future<void> updateGenderIdentity({
    required String userId,
    required GenderIdentity? genderIdentity,
  }) async {
    final currentState = state;
    if (currentState is ProfileLoadedState) {
      emit(ProfileActionLoadingState(profile: currentState.profile));
    }

    final result = await _updateGenderIdentityUseCase.invoke(
      userId: userId,
      genderIdentity: genderIdentity,
    );

    switch (result) {
      case Ok(value: final profile):
        emit(ProfileLoadedState(
          profile: profile,
          message: 'Identificação salva',
        ));
      case Error(error: final error) when error is ConnectionException:
        if (currentState is ProfileLoadedState) {
          emit(ProfileLoadedState(
            profile: currentState.profile,
            message: 'Sem conexão',
          ));
        } else {
          emit(const ProfileErrorState(message: 'Sem conexão'));
        }
      case Error():
        if (currentState is ProfileLoadedState) {
          emit(ProfileLoadedState(
            profile: currentState.profile,
            message: 'Erro ao salvar',
          ));
        } else {
          emit(const ProfileErrorState(message: 'Erro ao salvar'));
        }
    }
  }
}
