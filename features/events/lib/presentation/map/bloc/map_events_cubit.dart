import 'package:commons/commons.dart';
import 'package:injectable/injectable.dart';

import 'package:events/domain/model/event.dart';
import 'package:events/domain/usecase/events_usecases.dart';
import 'map_events_state.dart';

@injectable
class MapEventsCubit extends SafeCubit<MapEventsState> {
  MapEventsCubit(this._getUpcomingEventsUseCase)
    : super(const MapEventsInitialState());

  final GetUpcomingEventsUseCase _getUpcomingEventsUseCase;

  bool _isWoman = false;

  void setIsWoman(bool value) => _isWoman = value;

  Future<void> load({SportType? sportType}) async {
    emit(const MapEventsLoadingState());

    final result = await _getUpcomingEventsUseCase.invoke(sportType: sportType);

    switch (result) {
      case Ok(value: final events):
        final visible = events.where((event) {
          final hasLocation = event.location != null;
          final canSeeWomenOnly = _isWoman || !event.womenOnly;
          return hasLocation && canSeeWomenOnly;
        }).toList();

        emit(
          MapEventsLoadedState(
            events: visible,
            selectedSport: sportType ?? SportType.all,
          ),
        );
      case Error(error: final error) when error is ConnectionException:
        emit(const MapEventsErrorState(message: 'Sem conexao'));
      case Error(error: final error) when error is FirebaseDataException:
        emit(MapEventsErrorState(message: error.message));
      case Error():
        emit(const MapEventsErrorState(message: 'Erro ao carregar mapa'));
    }
  }

  Future<void> filterBySport(SportType sportType) {
    final filter = sportType == SportType.all ? null : sportType;
    return load(sportType: filter);
  }
}
