import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/model/event.dart';
import '../dto/db/event_db_dto.dart';

extension EventDbDtoMapper on EventDbDto {
  Event toDomain({required String id}) {
    return Event(
      id: id,
      title: title,
      description: description,
      sportType: _parseSportType(sportType),
      startAt: startAt.toDate(),
      endAt: endAt.toDate(),
      locationName: locationName,
      location: latitude != null && longitude != null
          ? GeoLocation(latitude: latitude!, longitude: longitude!)
          : null,
      hostId: hostId,
      hostName: hostName,
      maxParticipants: maxParticipants,
      participantIds: participantIds,
      womenOnly: womenOnly,
      tags: tags,
    );
  }
}

SportType _parseSportType(String value) {
  return SportType.values.firstWhere(
    (type) => type.name == value,
    orElse: () => SportType.other,
  );
}

extension EventDomainMapper on Event {
  EventDbDto toDbDto() {
    return EventDbDto(
      title: title,
      description: description,
      sportType: sportType.name,
      startAt: Timestamp.fromDate(startAt),
      endAt: Timestamp.fromDate(endAt),
      locationName: locationName,
      latitude: location?.latitude,
      longitude: location?.longitude,
      hostId: hostId,
      hostName: hostName,
      maxParticipants: maxParticipants,
      participantIds: participantIds,
      womenOnly: womenOnly,
      tags: tags,
    );
  }
}
