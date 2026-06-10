import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:events/domain/model/event.dart';
import 'package:events/presentation/create/bloc/create_event_cubit.dart';
import 'package:events/presentation/create/bloc/create_event_state.dart';
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
                    decoration: const InputDecoration(
                      labelText: EventsStrings.createLocationLabel,
                    ),
                    textInputAction: TextInputAction.next,
                    validator: _requiredValidator,
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
