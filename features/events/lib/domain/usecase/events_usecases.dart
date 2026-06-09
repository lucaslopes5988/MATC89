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
class JoinEventUseCase {
  const JoinEventUseCase(this._repository);

  final IEventsRepository _repository;

  AsyncResult<Event> invoke({required String eventId, required String userId}) {
    return _repository.joinEvent(eventId: eventId, userId: userId);
  }
}
