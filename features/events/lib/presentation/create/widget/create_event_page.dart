import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:events/domain/model/event.dart';
import 'package:events/presentation/create/bloc/create_event_cubit.dart';
import 'package:events/presentation/create/bloc/create_event_state.dart';
import 'package:events/presentation/create/widget/location_picker_field.dart';
import 'package:events/presentation/strings.dart';

class CreateEventPage extends StatelessWidget {
  const CreateEventPage({
    required this.userId,
    required this.userEmail,
    this.userDisplayName,
    super.key,
  });

  final String userId;
  final String userEmail;
  final String? userDisplayName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I.get<CreateEventCubit>(),
      child: _CreateEventView(
        userId: userId,
        userEmail: userEmail,
        userDisplayName: userDisplayName,
      ),
    );
  }
}

class _CreateEventView extends StatefulWidget {
  const _CreateEventView({
    required this.userId,
    required this.userEmail,
    this.userDisplayName,
  });

  final String userId;
  final String userEmail;
  final String? userDisplayName;

  @override
  State<_CreateEventView> createState() => _CreateEventViewState();
}

class _CreateEventViewState extends State<_CreateEventView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxParticipantsController = TextEditingController();

  SportType _sportType = SportType.running;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _womenOnly = false;
  LatLng? _selectedLocation;
  bool _isSearchingLocation = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(EventsStrings.createTitle)),
      body: BlocConsumer<CreateEventCubit, CreateEventState>(
        listener: (context, state) {
          if (state is CreateEventSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(EventsStrings.createSuccess)),
            );
            Navigator.of(context).pop(true);
          }

          if (state is CreateEventErrorState) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final isLoading = state is CreateEventLoadingState;

          return SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(PlayceSpacing.lg),
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: EventsStrings.createTitleLabel,
                    ),
                    textInputAction: TextInputAction.next,
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: PlayceSpacing.md),
                  DropdownButtonFormField<SportType>(
                    initialValue: _sportType,
                    decoration: const InputDecoration(
                      labelText: EventsStrings.createSportLabel,
                    ),
                    items: SportType.values
                        .where((sport) => sport != SportType.all)
                        .map(
                          (sport) => DropdownMenuItem(
                            value: sport,
                            child: Text(sportTypeLabel(sport)),
                          ),
                        )
                        .toList(),
                    onChanged: isLoading
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() => _sportType = value);
                            }
                          },
                  ),
                  const SizedBox(height: PlayceSpacing.md),
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: EventsStrings.createLocationLabel,
                      suffixIcon: _isSearchingLocation
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.search),
                              tooltip: EventsStrings.locationSearchAction,
                              onPressed: _searchLocation,
                            ),
                    ),
                    textInputAction: TextInputAction.search,
                    onFieldSubmitted: (_) => _searchLocation(),
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: PlayceSpacing.md),
                  LocationPickerField(
                    initialLocation: _selectedLocation,
                    onLocationSelected: (latLng) {
                      setState(() => _selectedLocation = latLng);
                    },
                  ),
                  const SizedBox(height: PlayceSpacing.md),
                  _DateTimeFields(
                    selectedDate: _selectedDate,
                    selectedTime: _selectedTime,
                    onSelectDate: isLoading ? null : _selectDate,
                    onSelectTime: isLoading ? null : _selectTime,
                  ),
                  const SizedBox(height: PlayceSpacing.md),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: EventsStrings.createDescriptionLabel,
                    ),
                    minLines: 3,
                    maxLines: 5,
                    textInputAction: TextInputAction.newline,
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: PlayceSpacing.md),
                  TextFormField(
                    controller: _maxParticipantsController,
                    decoration: const InputDecoration(
                      labelText: EventsStrings.createMaxParticipantsLabel,
                      helperText: EventsStrings.createMaxParticipantsHint,
                    ),
                    keyboardType: TextInputType.number,
                    validator: _maxParticipantsValidator,
                  ),
                  const SizedBox(height: PlayceSpacing.md),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(EventsStrings.createWomenOnlyLabel),
                    value: _womenOnly,
                    onChanged: isLoading
                        ? null
                        : (value) => setState(() => _womenOnly = value),
                  ),
                  const SizedBox(height: PlayceSpacing.xl),
                  PlaycePrimaryButton(
                    label: EventsStrings.createSubmit,
                    icon: Icons.check,
                    isLoading: isLoading,
                    onPressed: isLoading ? null : _submit,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _searchLocation() async {
    final query = _locationController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(EventsStrings.locationSearchEmpty)),
      );
      return;
    }

    setState(() => _isSearchingLocation = true);

    try {
      final locations = await geocoding.locationFromAddress(query);

      if (!mounted) return;

      if (locations.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(EventsStrings.locationNotFound)),
        );
        return;
      }

      if (locations.length == 1) {
        _applyGeocodingResult(locations.first);
        return;
      }

      final placemarks = await Future.wait(
        locations.take(5).map(
          (loc) => geocoding
              .placemarkFromCoordinates(loc.latitude, loc.longitude)
              .then((p) => (location: loc, placemark: p.firstOrNull))
              .catchError((_) => (location: loc, placemark: null as geocoding.Placemark?)),
        ),
      );

      if (!mounted) return;

      final selected = await showModalBottomSheet<geocoding.Location>(
        context: context,
        builder: (context) => _LocationResultsSheet(results: placemarks),
      );

      if (selected != null && mounted) {
        _applyGeocodingResult(selected);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(EventsStrings.locationNotFound)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSearchingLocation = false);
    }
  }

  void _applyGeocodingResult(geocoding.Location location) {
    final latLng = LatLng(location.latitude, location.longitude);
    setState(() => _selectedLocation = latLng);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(EventsStrings.locationFound)),
    );
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(EventsStrings.createDateTimeRequired)),
      );
      return;
    }

    final startAt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    if (!startAt.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(EventsStrings.createFutureDateRequired)),
      );
      return;
    }

    final maxParticipantsText = _maxParticipantsController.text.trim();
    final maxParticipants = maxParticipantsText.isEmpty
        ? 0
        : int.parse(maxParticipantsText);
    final hostName = widget.userDisplayName?.trim().isNotEmpty == true
        ? widget.userDisplayName!.trim()
        : widget.userEmail;

    final event = Event(
      id: '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      sportType: _sportType,
      startAt: startAt,
      endAt: startAt.add(const Duration(hours: 1)),
      locationName: _locationController.text.trim(),
      location: _selectedLocation != null
          ? GeoLocation(
              latitude: _selectedLocation!.latitude,
              longitude: _selectedLocation!.longitude,
            )
          : null,
      hostId: widget.userId,
      hostName: hostName,
      maxParticipants: maxParticipants,
      participantIds: [widget.userId],
      womenOnly: _womenOnly,
      tags: const [],
    );

    context.read<CreateEventCubit>().create(event);
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return EventsStrings.requiredField;
    }
    return null;
  }

  String? _maxParticipantsValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return null;
    }

    final number = int.tryParse(text);
    if (number == null || number < 1) {
      return EventsStrings.invalidMaxParticipants;
    }

    return null;
  }
}

class _DateTimeFields extends StatelessWidget {
  const _DateTimeFields({
    required this.selectedDate,
    required this.selectedTime,
    required this.onSelectDate,
    required this.onSelectTime,
  });

  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final VoidCallback? onSelectDate;
  final VoidCallback? onSelectTime;

  @override
  Widget build(BuildContext context) {
    final dateText = selectedDate == null
        ? EventsStrings.createDateLabel
        : MaterialLocalizations.of(context).formatMediumDate(selectedDate!);
    final timeText = selectedTime == null
        ? EventsStrings.createTimeLabel
        : selectedTime!.format(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonWidth = constraints.maxWidth > 420
            ? (constraints.maxWidth - PlayceSpacing.md) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: PlayceSpacing.md,
          runSpacing: PlayceSpacing.sm,
          children: [
            SizedBox(
              width: buttonWidth,
              child: OutlinedButton.icon(
                onPressed: onSelectDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(dateText, overflow: TextOverflow.ellipsis),
              ),
            ),
            SizedBox(
              width: buttonWidth,
              child: OutlinedButton.icon(
                onPressed: onSelectTime,
                icon: const Icon(Icons.schedule),
                label: Text(timeText, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LocationResultsSheet extends StatelessWidget {
  const _LocationResultsSheet({required this.results});

  final List<({geocoding.Location location, geocoding.Placemark? placemark})>
      results;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PlayceSpacing.lg,
              PlayceSpacing.lg,
              PlayceSpacing.lg,
              PlayceSpacing.sm,
            ),
            child: Text(
              'Selecione o local',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: results.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final result = results[index];
                final title = _formatPlacemark(result.placemark);
                final subtitle =
                    '${result.location.latitude.toStringAsFixed(5)}, '
                    '${result.location.longitude.toStringAsFixed(5)}';

                return ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text(subtitle),
                  onTap: () => Navigator.pop(context, result.location),
                );
              },
            ),
          ),
        ],
      ),
    );
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
