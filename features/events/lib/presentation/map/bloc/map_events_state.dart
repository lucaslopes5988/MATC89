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
    this.selectedDate,
    this.startMinute,
    this.endMinute,
  });

  final List<Event> events;
  final SportType selectedSport;
  final DateTime? selectedDate;
  final int? startMinute;
  final int? endMinute;

  @override
  List<Object?> get props => [
    events,
    selectedSport,
    selectedDate,
    startMinute,
    endMinute,
  ];
}

final class MapEventsErrorState extends MapEventsState {
  const MapEventsErrorState({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
