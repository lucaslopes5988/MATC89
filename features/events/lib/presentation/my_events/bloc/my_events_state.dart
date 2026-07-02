import 'package:equatable/equatable.dart';

import 'package:events/domain/model/event.dart';

sealed class MyEventsState extends Equatable {
  const MyEventsState();

  @override
  List<Object?> get props => [];
}

final class MyEventsInitialState extends MyEventsState {
  const MyEventsInitialState();
}

final class MyEventsLoadingState extends MyEventsState {
  const MyEventsLoadingState();
}

final class MyEventsLoadedState extends MyEventsState {
  const MyEventsLoadedState({required this.events});

  final List<Event> events;

  @override
  List<Object?> get props => [events];
}

final class MyEventsErrorState extends MyEventsState {
  const MyEventsErrorState({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
