import 'package:commons/commons.dart';
import 'package:injectable/injectable.dart';

import 'package:events/domain/usecase/events_usecases.dart';
import 'my_events_state.dart';

@injectable
class MyEventsCubit extends SafeCubit<MyEventsState> {
  MyEventsCubit(this._getJoinedEventsUseCase)
    : super(const MyEventsInitialState());

  final GetJoinedEventsUseCase _getJoinedEventsUseCase;

  Future<void> load(String userId) async {
    emit(const MyEventsLoadingState());

    final result = await _getJoinedEventsUseCase.invoke(userId);

    switch (result) {
      case Ok(value: final events):
        emit(MyEventsLoadedState(events: events));
      case Error(error: final error) when error is ConnectionException:
        emit(const MyEventsErrorState(message: 'Sem conexao'));
      case Error(error: final error) when error is FirebaseDataException:
        emit(MyEventsErrorState(message: error.message));
      case Error():
        emit(const MyEventsErrorState(message: 'Erro ao carregar sua agenda'));
    }
  }
}
