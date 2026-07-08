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

 bool _isWoman = false;
 List<Event> _allEvents = [];
 String _query = '';
 SportType _selectedSport = SportType.all;

 void setIsWoman(bool value) => _isWoman = value;

 Future<void> load({SportType? sportType}) async {
 emit(const ExploreLoadingState());

 _selectedSport = sportType ?? SportType.all;

 final result = await _getUpcomingEventsUseCase.invoke(sportType: sportType);

 switch (result) {
 case Ok(value: final events):
   _allEvents = _isWoman
       ? events
       : events.where((e) => !e.womenOnly).toList();
   _emitFiltered();
 case Error(error: final error) when error is ConnectionException:
 emit(const ExploreErrorState(message: 'Sem conexão'));
 case Error(error: final error) when error is FirebaseDataException:
 emit(ExploreErrorState(message: error.message));
 case Error():
 emit(const ExploreErrorState(message: 'Erro ao carregar eventos'));
 }
 }

 void search(String query) {
   _query = query.trim().toLowerCase();
   _emitFiltered();
 }

 void _emitFiltered() {
   var filtered = _allEvents;

   if (_query.isNotEmpty) {
     filtered = filtered.where((e) {
       final q = _query;
       return e.title.toLowerCase().contains(q) ||
           e.description.toLowerCase().contains(q) ||
           e.locationName.toLowerCase().contains(q) ||
           e.tags.any((tag) => tag.toLowerCase().contains(q));
     }).toList();
   }

   emit(
     ExploreLoadedState(
       events: filtered,
       selectedSport: _selectedSport,
       query: _query,
     ),
   );
 }

 Future<void> filterBySport(SportType sportType) {
 _query = '';
 final filter = sportType == SportType.all ? null : sportType;
 return load(sportType: filter);
 }
}
