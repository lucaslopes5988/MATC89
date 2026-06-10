import 'package:equatable/equatable.dart';

sealed class CreateEventState extends Equatable {
  const CreateEventState();

  @override
  List<Object?> get props => [];
}

final class CreateEventInitialState extends CreateEventState {
  const CreateEventInitialState();
}

final class CreateEventLoadingState extends CreateEventState {
  const CreateEventLoadingState();
}

final class CreateEventSuccessState extends CreateEventState {
  const CreateEventSuccessState();
}

final class CreateEventErrorState extends CreateEventState {
  const CreateEventErrorState({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
