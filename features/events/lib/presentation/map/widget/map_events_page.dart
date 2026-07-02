import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:events/domain/model/event.dart';
import 'package:events/presentation/details/widget/event_details_page.dart';
import 'package:events/presentation/map/bloc/map_events_cubit.dart';
import 'package:events/presentation/map/bloc/map_events_state.dart';
import 'package:events/presentation/strings.dart';

class MapEventsPage extends StatefulWidget {
  const MapEventsPage({required this.userId, this.isWoman = false, super.key});

  final String userId;
  final bool isWoman;

  @override
  State<MapEventsPage> createState() => _MapEventsPageState();
}

class _MapEventsPageState extends State<MapEventsPage> {
  late final MapEventsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.I.get<MapEventsCubit>()
      ..setIsWoman(widget.isWoman)
      ..load();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: _MapEventsView(userId: widget.userId, isWoman: widget.isWoman),
    );
  }
}

class _MapEventsView extends StatefulWidget {
  const _MapEventsView({required this.userId, required this.isWoman});

  final String userId;
  final bool isWoman;

  @override
  State<_MapEventsView> createState() => _MapEventsViewState();
}

class _MapEventsViewState extends State<_MapEventsView> {
  GoogleMapController? _mapController;

  static const _defaultLocation = LatLng(-15.7801, -47.9292);
  static const _defaultZoom = 12.0;
  static const _filters = [
    SportType.all,
    SportType.running,
    SportType.soccer,
    SportType.yoga,
    SportType.cycling,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<MapEventsCubit, MapEventsState>(
          listener: (context, state) {
            if (state is MapEventsLoadedState) {
              _fitEvents(state.events);
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                Positioned.fill(child: _buildMap(context, state)),
                Positioned(
                  top: PlayceSpacing.md,
                  left: 0,
                  right: 0,
                  child: _FilterBar(filters: _filters, state: state),
                ),
                if (state is MapEventsLoadingState ||
                    state is MapEventsInitialState)
                  const Center(child: CircularProgressIndicator()),
                if (state is MapEventsErrorState)
                  PlayceEmptyState(
                    title: 'Ops!',
                    message: state.message,
                    icon: Icons.cloud_off_outlined,
                  ),
                if (state is MapEventsLoadedState && state.events.isEmpty)
                  const _MapEmptyOverlay(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMap(BuildContext context, MapEventsState state) {
    final events = state is MapEventsLoadedState ? state.events : <Event>[];
    final target = events.firstOrNull?.location;

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: target == null
            ? _defaultLocation
            : LatLng(target.latitude, target.longitude),
        zoom: target == null ? _defaultZoom : 13,
      ),
      markers: events.map((event) => _markerFor(context, event)).toSet(),
      onMapCreated: (controller) {
        _mapController = controller;
        _fitEvents(events);
      },
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
    );
  }

  Marker _markerFor(BuildContext context, Event event) {
    final location = event.location!;
    final position = LatLng(location.latitude, location.longitude);

    return Marker(
      markerId: MarkerId(event.id),
      position: position,
      infoWindow: InfoWindow(title: event.title, snippet: event.locationName),
      onTap: () {
        _mapController?.animateCamera(CameraUpdate.newLatLng(position));
        _showEventSheet(context, event);
      },
    );
  }

  Future<void> _fitEvents(List<Event> events) async {
    if (events.isEmpty || _mapController == null) {
      return;
    }

    if (events.length == 1) {
      final location = events.first.location!;
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(location.latitude, location.longitude),
          14,
        ),
      );
      return;
    }

    final locations = events.map((event) => event.location!).toList();
    final south = locations
        .map((location) => location.latitude)
        .reduce((a, b) => a < b ? a : b);
    final west = locations
        .map((location) => location.longitude)
        .reduce((a, b) => a < b ? a : b);
    final north = locations
        .map((location) => location.latitude)
        .reduce((a, b) => a > b ? a : b);
    final east = locations
        .map((location) => location.longitude)
        .reduce((a, b) => a > b ? a : b);

    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(south, west),
          northeast: LatLng(north, east),
        ),
        72,
      ),
    );
  }

  Future<void> _showEventSheet(BuildContext context, Event event) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (_) => _MapEventSheet(
        event: event,
        userId: widget.userId,
        isWoman: widget.isWoman,
      ),
    );

    if (changed == true && context.mounted) {
      final state = context.read<MapEventsCubit>().state;
      final selectedSport = state is MapEventsLoadedState
          ? state.selectedSport
          : SportType.all;
      await context.read<MapEventsCubit>().filterBySport(selectedSport);
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.filters, required this.state});

  final List<SportType> filters;
  final MapEventsState state;

  @override
  Widget build(BuildContext context) {
    final selectedSport = state is MapEventsLoadedState
        ? (state as MapEventsLoadedState).selectedSport
        : SportType.all;

    return SizedBox(
      height: 44,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: PlayceSpacing.md),
        child: Row(
          children: [
            for (int i = 0; i < filters.length; i++) ...[
              if (i > 0) const SizedBox(width: PlayceSpacing.sm),
              FilterChip(
                label: Text(sportTypeLabel(filters[i])),
                selected: selectedSport == filters[i],
                onSelected: (_) =>
                    context.read<MapEventsCubit>().filterBySport(filters[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MapEventSheet extends StatelessWidget {
  const _MapEventSheet({
    required this.event,
    required this.userId,
    required this.isWoman,
  });

  final Event event;
  final String userId;
  final bool isWoman;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          PlayceSpacing.lg,
          PlayceSpacing.sm,
          PlayceSpacing.lg,
          PlayceSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: PlayceSpacing.sm,
              runSpacing: PlayceSpacing.xs,
              children: [
                Chip(label: Text(sportTypeLabel(event.sportType))),
                if (event.womenOnly)
                  Chip(
                    avatar: const Icon(Icons.female, size: 16),
                    label: const Text(EventsStrings.womenOnlyBadge),
                  ),
              ],
            ),
            const SizedBox(height: PlayceSpacing.sm),
            Text(event.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: PlayceSpacing.xs),
            Text(
              event.locationName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: PlayceColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: PlayceSpacing.md),
            SizedBox(
              width: double.infinity,
              child: PlaycePrimaryButton(
                label: EventsStrings.detailsButton,
                icon: Icons.event_available_outlined,
                onPressed: () async {
                  final changed = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => EventDetailsPage(
                        event: event,
                        userId: userId,
                        isWoman: isWoman,
                      ),
                    ),
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop(changed);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapEmptyOverlay extends StatelessWidget {
  const _MapEmptyOverlay();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(PlayceSpacing.md),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(PlayceSpacing.md),
            child: Text(
              EventsStrings.mapEmptyMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ),
    );
  }
}
