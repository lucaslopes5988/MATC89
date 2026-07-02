import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:events/presentation/strings.dart';

class LocationPermissionHandler {
  static Future<Position?> requestLocationWithPermission(
    BuildContext context,
  ) async {
    var status = await Permission.location.status;

    if (status.isDenied) {
      status = await Permission.location.request();
    }

    if (status.isPermanentlyDenied && context.mounted) {
      final shouldOpen = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(EventsStrings.locationPermissionTitle),
          content: const Text(EventsStrings.locationPermissionDenied),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                EventsStrings.locationPermissionOpenSettings,
              ),
            ),
          ],
        ),
      );

      if (shouldOpen == true) {
        await openAppSettings();
      }
      return null;
    }

    if (!status.isGranted) return null;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }
}
