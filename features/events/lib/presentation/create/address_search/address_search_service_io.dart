import 'package:geocoding/geocoding.dart' as geocoding;

import 'address_search_result.dart';

class AddressSearchService {
  Future<List<AddressSearchResult>> search(String query) async {
    final locations = await geocoding.locationFromAddress(query);

    final results = await Future.wait(
      locations.take(5).map((location) async {
        final placemark = await _placemarkFor(location);
        final title = _formatPlacemark(placemark);
        final subtitle = [
          location.latitude.toStringAsFixed(5),
          location.longitude.toStringAsFixed(5),
        ].join(', ');

        return AddressSearchResult(
          title: title,
          subtitle: subtitle,
          latitude: location.latitude,
          longitude: location.longitude,
        );
      }),
    );

    return results;
  }

  Future<geocoding.Placemark?> _placemarkFor(
    geocoding.Location location,
  ) async {
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      return placemarks.firstOrNull;
    } catch (_) {
      return null;
    }
  }

  String _formatPlacemark(geocoding.Placemark? placemark) {
    if (placemark == null) return 'Local encontrado';

    final parts = <String>[
      if (placemark.street?.isNotEmpty == true) placemark.street!,
      if (placemark.subLocality?.isNotEmpty == true) placemark.subLocality!,
      if (placemark.locality?.isNotEmpty == true) placemark.locality!,
      if (placemark.administrativeArea?.isNotEmpty == true)
        placemark.administrativeArea!,
    ];

    return parts.isEmpty ? 'Local encontrado' : parts.join(', ');
  }
}
