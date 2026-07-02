import 'package:commons/commons.dart';
import 'package:injectable/injectable.dart';

import '../model/event.dart';
import '../repository/i_events_repository.dart';

@injectable
class GetUpcomingEventsUseCase {
  const GetUpcomingEventsUseCase(this._repository);

  final IEventsRepository _repository;

  AsyncResult<List<Event>> invoke({SportType? sportType}) {
    return _repository.getUpcomingEvents(sportType: sportType);
  }
}

@injectable
class GetJoinedEventsUseCase {
  const GetJoinedEventsUseCase(this._repository);

  final IEventsRepository _repository;

  AsyncResult<List<Event>> invoke(String userId) {
    return _repository.getJoinedEvents(userId);
  }
}

@injectable
class GetEventByIdUseCase {
  const GetEventByIdUseCase(this._repository);

  final IEventsRepository _repository;

  AsyncResult<Event> invoke(String eventId) {
    return _repository.getEventById(eventId);
  }
}

@injectable
class JoinEventUseCase {
  const JoinEventUseCase(this._repository);

  final IEventsRepository _repository;

  AsyncResult<Event> invoke({required String eventId, required String userId}) {
    return _repository.joinEvent(eventId: eventId, userId: userId);
  }
}

@injectable
class LeaveEventUseCase {
  const LeaveEventUseCase(this._repository);

  final IEventsRepository _repository;

  AsyncResult<Event> invoke({required String eventId, required String userId}) {
    return _repository.leaveEvent(eventId: eventId, userId: userId);
  }
}

@injectable
class CreateEventUseCase {
  const CreateEventUseCase(this._repository);

  final IEventsRepository _repository;

  AsyncResult<Event> invoke(Event event) {
    return _repository.createEvent(event);
  }
}
