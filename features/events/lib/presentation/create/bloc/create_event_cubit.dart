import 'package:commons/commons.dart';
import 'package:injectable/injectable.dart';

import 'package:events/domain/model/event.dart';
import 'package:events/domain/usecase/events_usecases.dart';
import 'create_event_state.dart';

@injectable
class CreateEventCubit extends SafeCubit<CreateEventState> {
  CreateEventCubit(this._createEventUseCase)
    : super(const CreateEventInitialState());

  final CreateEventUseCase _createEventUseCase;

  Future<void> create(Event event) async {
    emit(const CreateEventLoadingState());

    final result = await _createEventUseCase.invoke(event);
    switch (result) {
      case Ok():
        emit(const CreateEventSuccessState());
      case Error(error: final error) when error is ConnectionException:
        emit(const CreateEventErrorState(message: 'Sem conexao'));
      case Error(error: final error) when error is FirebaseDataException:
        emit(CreateEventErrorState(message: error.message));
      case Error():
        emit(const CreateEventErrorState(message: 'Erro ao criar evento'));
    }
  }
}
