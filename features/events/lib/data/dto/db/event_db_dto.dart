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
 this.geopoint,
 this.geohash,
 });

 final String title;
 final String description;
 final String sportType;
 final Timestamp startAt;
 final Timestamp endAt;
 final String locationName;
 final GeoPoint? geopoint;
 final String? geohash;
 final String hostId;
 final String hostName;
 final int maxParticipants;
 final List<String> participantIds;
 final bool womenOnly;
 final List<String> tags;

 factory EventDbDto.fromFirestore(Map<String, dynamic> data) {
 GeoPoint? geopoint;
 String? geohash;

 final position = data['position'] as Map<String, dynamic>?;
 if (position != null) {
   geopoint = position['geopoint'] as GeoPoint?;
   geohash = position['geohash'] as String?;
 } else {
   final lat = (data['latitude'] as num?)?.toDouble();
   final lng = (data['longitude'] as num?)?.toDouble();
   if (lat != null && lng != null) {
     geopoint = GeoPoint(lat, lng);
   }
 }

 return EventDbDto(
 title: data['title'] as String? ?? '',
 description: data['description'] as String? ?? '',
 sportType: data['sportType'] as String? ?? 'other',
 startAt: data['startAt'] as Timestamp? ?? Timestamp.now(),
 endAt: data['endAt'] as Timestamp? ?? Timestamp.now(),
 locationName: data['locationName'] as String? ?? '',
 geopoint: geopoint,
 geohash: geohash,
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
 final map = <String, dynamic>{
 'title': title,
 'description': description,
 'sportType': sportType,
 'startAt': startAt,
 'endAt': endAt,
 'locationName': locationName,
 'hostId': hostId,
 'hostName': hostName,
 'maxParticipants': maxParticipants,
 'participantIds': participantIds,
 'womenOnly': womenOnly,
 'tags': tags,
 };

 if (geopoint != null) {
   map['position'] = {
     'geopoint': geopoint,
     'geohash': geohash,
   };
 }

 return map;
 }
}
