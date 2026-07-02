import 'dart:io' show Platform;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:events/domain/model/event.dart';

class EventLocationMap extends StatelessWidget {
  const EventLocationMap({required this.location, super.key});

  final GeoLocation location;

  @override
  Widget build(BuildContext context) {
    final target = LatLng(location.latitude, location.longitude);

    return GestureDetector(
      onTap: _openInMaps,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(PlayceRadius.md),
            child: SizedBox(
              height: 180,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: target,
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('event_location'),
                    position: target,
                  ),
                },
                liteModeEnabled: Platform.isAndroid,
                zoomControlsEnabled: false,
                scrollGesturesEnabled: false,
                tiltGesturesEnabled: false,
                rotateGesturesEnabled: false,
                zoomGesturesEnabled: false,
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
              ),
            ),
          ),
          Positioned(
            right: PlayceSpacing.sm,
            bottom: PlayceSpacing.sm,
            child: Material(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(8),
              elevation: 2,
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: PlayceSpacing.sm,
                  vertical: PlayceSpacing.xs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.open_in_new, size: 16, color: PlayceColors.primary),
                    SizedBox(width: 4),
                    Text(
                      'Abrir no mapa',
                      style: TextStyle(
                        fontSize: 12,
                        color: PlayceColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openInMaps() async {
    final lat = location.latitude;
    final lng = location.longitude;

    final url = Platform.isIOS
        ? Uri.parse('https://maps.apple.com/?ll=$lat,$lng&q=$lat,$lng')
        : Uri.parse('geo:$lat,$lng?q=$lat,$lng');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      final fallback = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      );
      await launchUrl(fallback, mode: LaunchMode.externalApplication);
    }
  }
}
