import 'package:commons/commons.dart';
import 'package:injectable/injectable.dart';

import 'package:events/domain/model/event.dart';
import 'package:events/domain/usecase/events_usecases.dart';
import 'explore_state.dart';

@injectable
class ExploreCubit extends SafeCubit<ExploreState> {
  ExploreCubit(this._getUpcomingEventsUseCase)
    : super(const ExploreInitialState());

  final GetUpcomingEventsUseCase _getUpcomingEventsUseCase;

  Future<void> load({SportType? sportType}) async {
    emit(const ExploreLoadingState());

    final result = await _getUpcomingEventsUseCase.invoke(sportType: sportType);

    switch (result) {
      case Ok(value: final events):
        emit(
          ExploreLoadedState(
            events: events,
            selectedSport: sportType ?? SportType.all,
          ),
        );
      case Error(error: final error) when error is ConnectionException:
        emit(const ExploreErrorState(message: 'Sem conexão'));
      case Error(error: final error) when error is FirebaseDataException:
        emit(ExploreErrorState(message: error.message));
      case Error():
        emit(const ExploreErrorState(message: 'Erro ao carregar eventos'));
    }
  }

  Future<void> filterBySport(SportType sportType) {
    final filter = sportType == SportType.all ? null : sportType;
    return load(sportType: filter);
  }
}
