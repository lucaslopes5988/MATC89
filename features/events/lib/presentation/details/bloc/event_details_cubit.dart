import 'package:commons/commons.dart';
import 'package:injectable/injectable.dart';

import 'package:events/domain/model/event.dart';
import 'package:events/domain/usecase/events_usecases.dart';
import 'event_details_state.dart';

@injectable
class EventDetailsCubit extends SafeCubit<EventDetailsState> {
  EventDetailsCubit(
    this._getEventByIdUseCase,
    this._joinEventUseCase,
    this._leaveEventUseCase,
  ) : super(const EventDetailsInitialState());

  final GetEventByIdUseCase _getEventByIdUseCase;
  final JoinEventUseCase _joinEventUseCase;
  final LeaveEventUseCase _leaveEventUseCase;

  Future<void> load(Event initialEvent) async {
    emit(EventDetailsLoadedState(event: initialEvent));

    final result = await _getEventByIdUseCase.invoke(initialEvent.id);
    switch (result) {
      case Ok(value: final event):
        emit(EventDetailsLoadedState(event: event));
      case Error(error: final error):
        emit(EventDetailsErrorState(message: _messageFor(error)));
    }
  }

  Future<void> join(Event event, String userId) async {
    emit(EventDetailsActionLoadingState(event: event));

    final result = await _joinEventUseCase.invoke(
      eventId: event.id,
      userId: userId,
    );
    switch (result) {
      case Ok(value: final updatedEvent):
        emit(
          EventDetailsLoadedState(
            event: updatedEvent,
            message: 'Presenca confirmada',
          ),
        );
      case Error(error: final error):
        emit(
          EventDetailsLoadedState(event: event, message: _messageFor(error)),
        );
    }
  }

  Future<void> leave(Event event, String userId) async {
    emit(EventDetailsActionLoadingState(event: event));

    final result = await _leaveEventUseCase.invoke(
      eventId: event.id,
      userId: userId,
    );
    switch (result) {
      case Ok(value: final updatedEvent):
        emit(
          EventDetailsLoadedState(
            event: updatedEvent,
            message: 'Presenca cancelada',
          ),
        );
      case Error(error: final error):
        emit(
          EventDetailsLoadedState(event: event, message: _messageFor(error)),
        );
    }
  }

  String _messageFor(Exception error) {
    return switch (error) {
      ConnectionException() => 'Sem conexao',
      EventFullException() => error.message,
      FirebaseDataException() => error.message,
      NotFoundException() => error.message,
      _ => 'Erro ao atualizar evento',
    };
  }
}
