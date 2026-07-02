import 'package:equatable/equatable.dart';

import 'package:profile/domain/model/user_profile.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileInitialState extends ProfileState {
  const ProfileInitialState();
}

final class ProfileLoadingState extends ProfileState {
  const ProfileLoadingState();
}

final class ProfileLoadedState extends ProfileState {
  const ProfileLoadedState({required this.profile, this.message});

  final UserProfile profile;
  final String? message;

  @override
  List<Object?> get props => [profile, message];
}

final class ProfileActionLoadingState extends ProfileState {
  const ProfileActionLoadingState({required this.profile});

  final UserProfile profile;

  @override
  List<Object?> get props => [profile];
}

final class ProfileErrorState extends ProfileState {
  const ProfileErrorState({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
