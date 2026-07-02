import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:events/presentation/shared/location_permission_handler.dart';
import 'package:events/presentation/strings.dart';

class LocationPickerField extends StatefulWidget {
  const LocationPickerField({
    required this.onLocationSelected,
    this.initialLocation,
    super.key,
  });

  final LatLng? initialLocation;
  final ValueChanged<LatLng?> onLocationSelected;

  @override
  State<LocationPickerField> createState() => _LocationPickerFieldState();
}

class _LocationPickerFieldState extends State<LocationPickerField> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  bool _loading = false;

  static const _defaultLocation = LatLng(-15.7801, -47.9292);
  static const _defaultZoom = 14.0;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  @override
  void didUpdateWidget(LocationPickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialLocation != oldWidget.initialLocation &&
        widget.initialLocation != null &&
        widget.initialLocation != _selectedLocation) {
      setState(() => _selectedLocation = widget.initialLocation);
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(widget.initialLocation!, _defaultZoom),
      );
    }
  }

  Set<Marker> get _markers {
    if (_selectedLocation == null) return {};
    return {
      Marker(
        markerId: const MarkerId('event_location'),
        position: _selectedLocation!,
        draggable: true,
        onDragEnd: _onMarkerDrag,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: TextButton.icon(
            onPressed: _loading ? null : _useMyLocation,
            icon: _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location, size: 18),
            label: const Text(EventsStrings.locationPickerUseMyLocation),
          ),
        ),
        const SizedBox(height: PlayceSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(PlayceRadius.md),
          child: SizedBox(
            height: 200,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selectedLocation ?? _defaultLocation,
                zoom: _defaultZoom,
              ),
              markers: _markers,
              onMapCreated: (controller) => _mapController = controller,
              onTap: _onMapTap,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),
          ),
        ),
        if (_selectedLocation == null) ...[
          const SizedBox(height: PlayceSpacing.xs),
          Text(
            EventsStrings.locationPickerHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PlayceColors.onSurfaceVariant,
                ),
          ),
        ],
      ],
    );
  }

  void _onMapTap(LatLng position) {
    setState(() => _selectedLocation = position);
    widget.onLocationSelected(position);
  }

  void _onMarkerDrag(LatLng position) {
    setState(() => _selectedLocation = position);
    widget.onLocationSelected(position);
  }

  Future<void> _useMyLocation() async {
    setState(() => _loading = true);

    try {
      final position =
          await LocationPermissionHandler.requestLocationWithPermission(
        context,
      );

      if (position != null && mounted) {
        final latLng = LatLng(position.latitude, position.longitude);
        setState(() => _selectedLocation = latLng);
        widget.onLocationSelected(latLng);
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(latLng, _defaultZoom),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
