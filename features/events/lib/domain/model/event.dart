import 'package:equatable/equatable.dart';

enum SportType {
  all,
  running,
  soccer,
  yoga,
  cycling,
  tennis,
  hiit,
  swimming,
  other,
}

class GeoLocation extends Equatable {
 const GeoLocation({
   required this.latitude,
   required this.longitude,
   this.geohash,
 });

 final double latitude;
 final double longitude;
 final String? geohash;

 @override
 List<Object?> get props => [latitude, longitude, geohash];
}

class Event extends Equatable {
  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.sportType,
    required this.startAt,
    required this.endAt,
    required this.locationName,
    required this.hostId,
    required this.hostName,
    required this.maxParticipants,
    required this.participantIds,
    required this.womenOnly,
    required this.tags,
    this.location,
  });

  final String id;
  final String title;
  final String description;
  final SportType sportType;
  final DateTime startAt;
  final DateTime endAt;
  final String locationName;
  final GeoLocation? location;
  final String hostId;
  final String hostName;
  final int maxParticipants;
  final List<String> participantIds;
  final bool womenOnly;
  final List<String> tags;

  int get participantCount => participantIds.length;

  int? get slotsLeft {
    if (maxParticipants <= 0) {
      return null;
    }
    final remaining = maxParticipants - participantCount;
    return remaining < 0 ? 0 : remaining;
  }

  bool get isFull => slotsLeft == 0;

  bool isJoinedBy(String userId) => participantIds.contains(userId);

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    sportType,
    startAt,
    endAt,
    locationName,
    location,
    hostId,
    hostName,
    maxParticipants,
    participantIds,
    womenOnly,
    tags,
  ];
}
