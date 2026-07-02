import 'dart:typed_data';
import 'dart:ui' as ui;

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
  Set<Marker> _markers = const {};
  String _markersSignature = '';
  final Map<int, BitmapDescriptor> _markerIconCache = {};

  static const _defaultLocation = LatLng(-15.7801, -47.9292);
  static const _defaultZoom = 12.0;
  static const _mapStyle = '''
[
  {
    "featureType": "poi",
    "stylers": [
      { "visibility": "off" }
    ]
  },
  {
    "featureType": "transit",
    "stylers": [
      { "visibility": "off" }
    ]
  }
]
''';
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
    _scheduleMarkersRefresh(context, events);

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: target == null
            ? _defaultLocation
            : LatLng(target.latitude, target.longitude),
        zoom: target == null ? _defaultZoom : 13,
      ),
      markers: _markers,
      style: _mapStyle,
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

  void _scheduleMarkersRefresh(BuildContext context, List<Event> events) {
    final signature = events
        .map(
          (event) =>
              '${event.id}:${event.location?.latitude}:${event.location?.longitude}',
        )
        .join('|');

    if (signature == _markersSignature) {
      return;
    }

    _markersSignature = signature;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _refreshMarkers(context, events);
      }
    });
  }

  Future<void> _refreshMarkers(BuildContext context, List<Event> events) async {
    if (events.isEmpty) {
      if (mounted) {
        setState(() => _markers = const {});
      }
      return;
    }

    final groups = _clusterEvents(events);
    final markers = <Marker>{};

    for (final group in groups) {
      final count = group.events.length;
      final icon = await _markerIconForCount(count);
      final position = group.position;
      final label = count == 1 ? group.events.first.title : '$count eventos';
      final snippet = count == 1
          ? group.events.first.locationName
          : 'Toque para ver os eventos próximos';

      markers.add(
        Marker(
          markerId: MarkerId(group.id),
          position: position,
          icon: icon,
          infoWindow: InfoWindow(title: label, snippet: snippet),
          anchor: const Offset(0.5, 0.5),
          onTap: () {
            _mapController?.animateCamera(CameraUpdate.newLatLng(position));
            if (count == 1) {
              _showEventSheet(context, group.events.first);
              return;
            }
            _showClusterSheet(context, group);
          },
        ),
      );
    }

    if (mounted) {
      setState(() => _markers = markers);
    }
  }

  List<_EventMarkerGroup> _clusterEvents(List<Event> events) {
    final grouped = <String, List<Event>>{};

    for (final event in events) {
      final location = event.location;
      if (location == null) continue;

      final latBucket = (location.latitude * 1000).round();
      final lngBucket = (location.longitude * 1000).round();
      final key = '$latBucket:$lngBucket';
      grouped.putIfAbsent(key, () => []).add(event);
    }

    return grouped.entries.map((entry) {
      final events = entry.value;
      final averageLat =
          events
              .map((event) => event.location!.latitude)
              .reduce((a, b) => a + b) /
          events.length;
      final averageLng =
          events
              .map((event) => event.location!.longitude)
              .reduce((a, b) => a + b) /
          events.length;

      return _EventMarkerGroup(
        id: events.length == 1 ? events.first.id : 'cluster-${entry.key}',
        position: LatLng(averageLat, averageLng),
        events: events,
      );
    }).toList();
  }

  Future<BitmapDescriptor> _markerIconForCount(int count) async {
    final cached = _markerIconCache[count];
    if (cached != null) {
      return cached;
    }

    final bytes = await _drawMarkerIcon(count);
    final icon = BitmapDescriptor.bytes(
      bytes,
      width: 48,
      height: 48,
      imagePixelRatio: 2,
    );
    _markerIconCache[count] = icon;
    return icon;
  }

  Future<Uint8List> _drawMarkerIcon(int count) async {
    const size = 96.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = Offset(size / 2, size / 2);

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center.translate(0, 3), 34, shadowPaint);

    final fillPaint = Paint()..color = PlayceColors.primary;
    canvas.drawCircle(center, 34, fillPaint);

    final ringPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawCircle(center, 31, ringPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: count > 99 ? '99+' : count.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: count > 9 ? 28 : 34,
          fontWeight: FontWeight.w800,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
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

  Future<void> _showClusterSheet(
    BuildContext context,
    _EventMarkerGroup group,
  ) async {
    final selected = await showModalBottomSheet<Event>(
      context: context,
      showDragHandle: true,
      builder: (_) => _MapClusterSheet(events: group.events),
    );

    if (selected != null && context.mounted) {
      await _showEventSheet(context, selected);
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

class _EventMarkerGroup {
  const _EventMarkerGroup({
    required this.id,
    required this.position,
    required this.events,
  });

  final String id;
  final LatLng position;
  final List<Event> events;
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

class _MapClusterSheet extends StatelessWidget {
  const _MapClusterSheet({required this.events});

  final List<Event> events;

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
            Text(
              '${events.length} eventos proximos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: PlayceSpacing.sm),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: events.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return _ClusterEventTile(event: events[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClusterEventTile extends StatelessWidget {
  const _ClusterEventTile({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(event),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: PlayceSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: PlayceSpacing.xs),
            Text(
              event.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: PlayceColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: PlayceSpacing.sm),
            Wrap(
              spacing: PlayceSpacing.md,
              runSpacing: PlayceSpacing.xs,
              children: [
                _ClusterEventMeta(
                  icon: Icons.calendar_today,
                  text: _formatEventDate(event.startAt),
                ),
                _ClusterEventMeta(
                  icon: Icons.groups_outlined,
                  text: _formatParticipants(event),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatEventDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }

  String _formatParticipants(Event event) {
    if (event.maxParticipants <= 0) {
      return '${event.participantCount} confirmados';
    }
    return '${event.participantCount}/${event.maxParticipants} confirmados';
  }
}

class _ClusterEventMeta extends StatelessWidget {
  const _ClusterEventMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: PlayceColors.onSurfaceVariant),
        const SizedBox(width: PlayceSpacing.xs),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: PlayceColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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
