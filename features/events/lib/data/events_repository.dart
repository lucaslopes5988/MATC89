import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:commons/commons.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:injectable/injectable.dart';

import 'datasource/firebase/events_firestore_data_source.dart';
import 'mapper/event_mapper.dart';
import '../../domain/model/event.dart';
import '../../domain/repository/i_events_repository.dart';

@Injectable(as: IEventsRepository)
class EventsRepository implements IEventsRepository {
  EventsRepository(this._dataSource);

  final EventsFirestoreDataSource _dataSource;

  @override
  AsyncResult<List<Event>> getUpcomingEvents({SportType? sportType}) async {
    try {
      final records = await _dataSource.getUpcomingEvents(
        sportType: sportType?.name,
      );
      final events = records
          .map((record) => record.dto.toDomain(id: record.id))
          .toList();
      return Result.ok(events);
    } on FirebaseException catch (error) {
      return Result.error(_mapFirebaseError(error));
    } catch (_) {
      return Result.error(
        const FirebaseDataException('Erro ao carregar eventos'),
      );
    }
  }

  @override
  AsyncResult<List<Event>> getJoinedEvents(String userId) async {
    try {
      final records = await _dataSource.getJoinedEvents(userId);
      final events = records
          .map((record) => record.dto.toDomain(id: record.id))
          .toList();
      return Result.ok(events);
    } on FirebaseException catch (error) {
      return Result.error(_mapFirebaseError(error));
    } catch (_) {
      return Result.error(
        const FirebaseDataException('Erro ao carregar sua agenda'),
      );
    }
  }

  @override
  AsyncResult<Event> getEventById(String eventId) async {
    try {
      final record = await _dataSource.getEventById(eventId);
      return Result.ok(record.dto.toDomain(id: record.id));
    } on StateError {
      return Result.error(const NotFoundException('Evento não encontrado'));
    } on FirebaseException catch (error) {
      return Result.error(_mapFirebaseError(error));
    } catch (_) {
      return Result.error(
        const FirebaseDataException('Erro ao carregar evento'),
      );
    }
  }

  @override
  AsyncResult<Event> createEvent(Event event) async {
    try {
      final record = await _dataSource.createEvent(event.toDbDto());
      return Result.ok(record.dto.toDomain(id: record.id));
    } on FirebaseException catch (error) {
      return Result.error(_mapFirebaseError(error));
    } catch (_) {
      return Result.error(const FirebaseDataException('Erro ao criar evento'));
    }
  }

  @override
  AsyncResult<Event> joinEvent({
    required String eventId,
    required String userId,
  }) async {
    try {
      final record = await _dataSource.joinEvent(
        eventId: eventId,
        userId: userId,
      );
      return Result.ok(record.dto.toDomain(id: record.id));
    } on StateError catch (error) {
      if (error.message == 'Event is full') {
        return Result.error(const EventFullException());
      }
      return Result.error(const NotFoundException('Evento não encontrado'));
    } on FirebaseException catch (error) {
      return Result.error(_mapFirebaseError(error));
    } catch (_) {
      return Result.error(
        const FirebaseDataException('Erro ao entrar no evento'),
      );
    }
  }

  @override
  AsyncResult<Event> leaveEvent({
    required String eventId,
    required String userId,
  }) async {
    try {
      final record = await _dataSource.leaveEvent(
        eventId: eventId,
        userId: userId,
      );
      return Result.ok(record.dto.toDomain(id: record.id));
    } on StateError catch (error) {
      if (error.message == 'Host cannot leave') {
        return Result.error(
          const FirebaseDataException(
            'O criador nao pode cancelar presenca nesta versao',
          ),
        );
      }
      return Result.error(const NotFoundException('Evento nao encontrado'));
    } on FirebaseException catch (error) {
      return Result.error(_mapFirebaseError(error));
    } catch (_) {
      return Result.error(
        const FirebaseDataException('Erro ao cancelar presenca'),
      );
    }
  }
}

Exception _mapFirebaseError(FirebaseException error) {
  if (error.code == 'unavailable' || error.code == 'network-request-failed') {
    return const ConnectionException();
  }
  return FirebaseDataException(error.message ?? 'Erro no Firestore');
}
