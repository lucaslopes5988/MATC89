import 'package:commons/commons.dart';

import '../model/event.dart';

abstract interface class IEventsRepository {
  AsyncResult<List<Event>> getUpcomingEvents({SportType? sportType});

  AsyncResult<List<Event>> getJoinedEvents(String userId);

  AsyncResult<Event> getEventById(String eventId);

  AsyncResult<Event> createEvent(Event event);

  AsyncResult<Event> joinEvent({
    required String eventId,
    required String userId,
  });

  AsyncResult<Event> leaveEvent({
    required String eventId,
    required String userId,
  });
}
