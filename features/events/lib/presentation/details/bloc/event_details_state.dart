import 'package:equatable/equatable.dart';

import 'package:events/domain/model/event.dart';

sealed class EventDetailsState extends Equatable {
  const EventDetailsState();

  @override
  List<Object?> get props => [];
}

final class EventDetailsInitialState extends EventDetailsState {
  const EventDetailsInitialState();
}

final class EventDetailsLoadingState extends EventDetailsState {
  const EventDetailsLoadingState();
}

final class EventDetailsLoadedState extends EventDetailsState {
  const EventDetailsLoadedState({required this.event, this.message});

  final Event event;
  final String? message;

  @override
  List<Object?> get props => [event, message];
}

final class EventDetailsActionLoadingState extends EventDetailsState {
  const EventDetailsActionLoadingState({required this.event});

  final Event event;

  @override
  List<Object?> get props => [event];
}

final class EventDetailsErrorState extends EventDetailsState {
  const EventDetailsErrorState({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
