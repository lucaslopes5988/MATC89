import 'package:equatable/equatable.dart';

import 'package:events/domain/model/event.dart';

sealed class MapEventsState extends Equatable {
  const MapEventsState();

  @override
  List<Object?> get props => [];
}

final class MapEventsInitialState extends MapEventsState {
  const MapEventsInitialState();
}

final class MapEventsLoadingState extends MapEventsState {
  const MapEventsLoadingState();
}

final class MapEventsLoadedState extends MapEventsState {
  const MapEventsLoadedState({
    required this.events,
    this.selectedSport = SportType.all,
  });

  final List<Event> events;
  final SportType selectedSport;

  @override
  List<Object?> get props => [events, selectedSport];
}

final class MapEventsErrorState extends MapEventsState {
  const MapEventsErrorState({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
