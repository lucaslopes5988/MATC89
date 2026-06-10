import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../dto/db/event_db_dto.dart';
import '../endpoint/endpoint.dart';

@injectable
class EventsFirestoreDataSource {
  EventsFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(EventsEndpoints.eventsCollection);

  Future<List<({EventDbDto dto, String id})>> getUpcomingEvents({
    String? sportType,
  }) async {
    Query<Map<String, dynamic>> query = _collection
        .where('startAt', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('startAt');

    if (sportType != null && sportType != 'all') {
      query = query.where('sportType', isEqualTo: sportType);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => (dto: EventDbDto.fromFirestore(doc.data()), id: doc.id))
        .toList();
  }

  Future<({EventDbDto dto, String id})> getEventById(String eventId) async {
    final doc = await _collection.doc(eventId).get();
    if (!doc.exists || doc.data() == null) {
      throw StateError('Event not found');
    }

    return (dto: EventDbDto.fromFirestore(doc.data()!), id: doc.id);
  }

  Future<({EventDbDto dto, String id})> createEvent(EventDbDto dto) async {
    final docRef = await _collection.add(dto.toFirestore());
    return (dto: dto, id: docRef.id);
  }

  Future<({EventDbDto dto, String id})> joinEvent({
    required String eventId,
    required String userId,
  }) async {
    final docRef = _collection.doc(eventId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists || snapshot.data() == null) {
        throw StateError('Event not found');
      }

      final dto = EventDbDto.fromFirestore(snapshot.data()!);
      if (dto.participantIds.contains(userId)) {
        return (dto: dto, id: snapshot.id);
      }

      if (dto.maxParticipants > 0 &&
          dto.participantIds.length >= dto.maxParticipants) {
        throw StateError('Event is full');
      }

      final updatedParticipants = [...dto.participantIds, userId];
      transaction.update(docRef, {'participantIds': updatedParticipants});

      return (
        dto: EventDbDto(
          title: dto.title,
          description: dto.description,
          sportType: dto.sportType,
          startAt: dto.startAt,
          endAt: dto.endAt,
          locationName: dto.locationName,
          latitude: dto.latitude,
          longitude: dto.longitude,
          hostId: dto.hostId,
          hostName: dto.hostName,
          maxParticipants: dto.maxParticipants,
          participantIds: updatedParticipants,
          womenOnly: dto.womenOnly,
          tags: dto.tags,
        ),
        id: snapshot.id,
      );
    });
  }

  Future<({EventDbDto dto, String id})> leaveEvent({
    required String eventId,
    required String userId,
  }) async {
    final docRef = _collection.doc(eventId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists || snapshot.data() == null) {
        throw StateError('Event not found');
      }

      final dto = EventDbDto.fromFirestore(snapshot.data()!);
      if (!dto.participantIds.contains(userId)) {
        return (dto: dto, id: snapshot.id);
      }

      if (dto.hostId == userId) {
        throw StateError('Host cannot leave');
      }

      final updatedParticipants = dto.participantIds
          .where((participantId) => participantId != userId)
          .toList();
      transaction.update(docRef, {'participantIds': updatedParticipants});

      return (
        dto: EventDbDto(
          title: dto.title,
          description: dto.description,
          sportType: dto.sportType,
          startAt: dto.startAt,
          endAt: dto.endAt,
          locationName: dto.locationName,
          latitude: dto.latitude,
          longitude: dto.longitude,
          hostId: dto.hostId,
          hostName: dto.hostName,
          maxParticipants: dto.maxParticipants,
          participantIds: updatedParticipants,
          womenOnly: dto.womenOnly,
          tags: dto.tags,
        ),
        id: snapshot.id,
      );
    });
  }
}
