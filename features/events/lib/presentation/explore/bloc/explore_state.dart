import 'package:equatable/equatable.dart';

import 'package:events/domain/model/event.dart';

sealed class ExploreState extends Equatable {
  const ExploreState();

  @override
  List<Object?> get props => [];
}

final class ExploreInitialState extends ExploreState {
  const ExploreInitialState();
}

final class ExploreLoadingState extends ExploreState {
  const ExploreLoadingState();
}

final class ExploreLoadedState extends ExploreState {
  const ExploreLoadedState({
    required this.events,
    this.selectedSport = SportType.all,
    this.query = '',
  });

  final List<Event> events;
  final SportType selectedSport;
  final String query;

  @override
  List<Object?> get props => [events, selectedSport, query];
}

final class ExploreErrorState extends ExploreState {
  const ExploreErrorState({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
