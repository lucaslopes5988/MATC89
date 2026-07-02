import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:events/data/geo/geohash_util.dart';

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
      location: geopoint != null
          ? GeoLocation(
              latitude: geopoint!.latitude,
              longitude: geopoint!.longitude,
              geohash: geohash,
            )
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
    GeoPoint? geopoint;
    String? geohash;

    if (location != null) {
      geopoint = GeoPoint(location!.latitude, location!.longitude);
      geohash = GeohashUtil.encode(location!.latitude, location!.longitude);
    }

    return EventDbDto(
      title: title,
      description: description,
      sportType: sportType.name,
      startAt: Timestamp.fromDate(startAt),
      endAt: Timestamp.fromDate(endAt),
      locationName: locationName,
      geopoint: geopoint,
      geohash: geohash,
      hostId: hostId,
      hostName: hostName,
      maxParticipants: maxParticipants,
      participantIds: participantIds,
      womenOnly: womenOnly,
      tags: tags,
    );
  }
}
