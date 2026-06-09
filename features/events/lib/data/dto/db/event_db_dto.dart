import 'package:cloud_firestore/cloud_firestore.dart';

class EventDbDto {
  const EventDbDto({
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
    this.latitude,
    this.longitude,
  });

  final String title;
  final String description;
  final String sportType;
  final Timestamp startAt;
  final Timestamp endAt;
  final String locationName;
  final double? latitude;
  final double? longitude;
  final String hostId;
  final String hostName;
  final int maxParticipants;
  final List<String> participantIds;
  final bool womenOnly;
  final List<String> tags;

  factory EventDbDto.fromFirestore(Map<String, dynamic> data) {
    return EventDbDto(
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      sportType: data['sportType'] as String? ?? 'other',
      startAt: data['startAt'] as Timestamp? ?? Timestamp.now(),
      endAt: data['endAt'] as Timestamp? ?? Timestamp.now(),
      locationName: data['locationName'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      hostId: data['hostId'] as String? ?? '',
      hostName: data['hostName'] as String? ?? '',
      maxParticipants: data['maxParticipants'] as int? ?? 0,
      participantIds: List<String>.from(
        data['participantIds'] as List<dynamic>? ?? const [],
      ),
      womenOnly: data['womenOnly'] as bool? ?? false,
      tags: List<String>.from(data['tags'] as List<dynamic>? ?? const []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'sportType': sportType,
      'startAt': startAt,
      'endAt': endAt,
      'locationName': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'hostId': hostId,
      'hostName': hostName,
      'maxParticipants': maxParticipants,
      'participantIds': participantIds,
      'womenOnly': womenOnly,
      'tags': tags,
    };
  }
}
