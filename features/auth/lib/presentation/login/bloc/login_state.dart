import 'package:equatable/equatable.dart';

import 'package:auth/domain/model/user.dart';

sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

final class LoginInitialState extends LoginState {
  const LoginInitialState();
}

final class LoginLoadingState extends LoginState {
  const LoginLoadingState();
}

final class LoginSuccessState extends LoginState {
  const LoginSuccessState({required this.user});

  final User user;

  @override
  List<Object?> get props => [user];
}

final class LoginErrorState extends LoginState {
  const LoginErrorState({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
