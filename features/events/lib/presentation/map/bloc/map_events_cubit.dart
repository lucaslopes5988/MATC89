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
  List<Event> _baseEvents = const [];
  SportType _selectedSport = SportType.all;
  DateTime? _selectedDate;
  int? _startMinute;
  int? _endMinute;

  void setIsWoman(bool value) => _isWoman = value;

  Future<void> load() async {
    emit(const MapEventsLoadingState());

    final result = await _getUpcomingEventsUseCase.invoke();

    switch (result) {
      case Ok(value: final events):
        _baseEvents = events.where((event) {
          final hasLocation = event.location != null;
          final canSeeWomenOnly = _isWoman || !event.womenOnly;
          return hasLocation && canSeeWomenOnly;
        }).toList();

        _emitFiltered();
      case Error(error: final error) when error is ConnectionException:
        emit(const MapEventsErrorState(message: 'Sem conexao'));
      case Error(error: final error) when error is FirebaseDataException:
        emit(MapEventsErrorState(message: error.message));
      case Error():
        emit(const MapEventsErrorState(message: 'Erro ao carregar mapa'));
    }
  }

  void filterBySport(SportType sportType) {
    _selectedSport = sportType;
    _emitFiltered();
  }

  void filterByDate(DateTime? date) {
    _selectedDate = date == null
        ? null
        : DateTime(date.year, date.month, date.day);
    _emitFiltered();
  }

  void filterByTimeRange({int? startMinute, int? endMinute}) {
    if (startMinute != null && endMinute != null && endMinute < startMinute) {
      _startMinute = endMinute;
      _endMinute = startMinute;
    } else {
      _startMinute = startMinute;
      _endMinute = endMinute;
    }
    _emitFiltered();
  }

  void clearFilters() {
    _selectedSport = SportType.all;
    _selectedDate = null;
    _startMinute = null;
    _endMinute = null;
    _emitFiltered();
  }

  void _emitFiltered() {
    final filtered = _baseEvents.where((event) {
      if (_selectedSport != SportType.all &&
          event.sportType != _selectedSport) {
        return false;
      }

      if (_selectedDate != null) {
        final start = event.startAt;
        final sameDay =
            start.year == _selectedDate!.year &&
            start.month == _selectedDate!.month &&
            start.day == _selectedDate!.day;
        if (!sameDay) return false;
      }

      final eventMinute = event.startAt.hour * 60 + event.startAt.minute;
      if (_startMinute != null && eventMinute < _startMinute!) {
        return false;
      }
      if (_endMinute != null && eventMinute > _endMinute!) {
        return false;
      }

      return true;
    }).toList();

    emit(
      MapEventsLoadedState(
        events: filtered,
        selectedSport: _selectedSport,
        selectedDate: _selectedDate,
        startMinute: _startMinute,
        endMinute: _endMinute,
      ),
    );
  }
}
