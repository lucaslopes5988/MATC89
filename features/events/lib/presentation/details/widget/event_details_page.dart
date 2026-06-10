import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:events/domain/model/event.dart';
import 'package:events/presentation/details/bloc/event_details_cubit.dart';
import 'package:events/presentation/details/bloc/event_details_state.dart';
import 'package:events/presentation/strings.dart';

class EventDetailsPage extends StatelessWidget {
  const EventDetailsPage({
    required this.event,
    required this.userId,
    super.key,
  });

  final Event event;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I.get<EventDetailsCubit>()..load(event),
      child: _EventDetailsView(userId: userId),
    );
  }
}

class _EventDetailsView extends StatefulWidget {
  const _EventDetailsView({required this.userId});

  final String userId;

  @override
  State<_EventDetailsView> createState() => _EventDetailsViewState();
}

class _EventDetailsViewState extends State<_EventDetailsView> {
  bool _changed = false;

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Navigator.of(context).pop(_changed);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(EventsStrings.detailsTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(_changed),
          ),
        ),
        body: BlocConsumer<EventDetailsCubit, EventDetailsState>(
          listener: (context, state) {
            if (state is EventDetailsLoadedState && state.message != null) {
              final changedMessages = {
                EventsStrings.joinSuccess,
                EventsStrings.leaveSuccess,
              };
              if (changedMessages.contains(state.message)) {
                _changed = true;
              }
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message!)));
            }
          },
          builder: (context, state) {
            return switch (state) {
              EventDetailsInitialState() || EventDetailsLoadingState() =>
                const Center(child: CircularProgressIndicator()),
              EventDetailsErrorState(:final message) => PlayceEmptyState(
                title: 'Ops!',
                message: message,
                icon: Icons.cloud_off_outlined,
              ),
              EventDetailsLoadedState(:final event) => _DetailsContent(
                event: event,
                userId: widget.userId,
                isActionLoading: false,
              ),
              EventDetailsActionLoadingState(:final event) => _DetailsContent(
                event: event,
                userId: widget.userId,
                isActionLoading: true,
              ),
            };
          },
        ),
      ),
    );
  }
}

class _DetailsContent extends StatelessWidget {
  const _DetailsContent({
    required this.event,
    required this.userId,
    required this.isActionLoading,
  });

  final Event event;
  final String userId;
  final bool isActionLoading;

  @override
  Widget build(BuildContext context) {
    final isJoined = event.isJoinedBy(userId);
    final isHost = event.hostId == userId;
    final canJoin = !isJoined && !event.isFull;
    final canLeave =
        isJoined && !isHost && event.startAt.isAfter(DateTime.now());

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(PlayceSpacing.md),
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
                    if (event.isFull)
                      const Chip(label: Text(EventsStrings.full)),
                  ],
                ),
                const SizedBox(height: PlayceSpacing.md),
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: PlayceSpacing.sm),
                Text(
                  event.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: PlayceColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: PlayceSpacing.lg),
                _InfoRow(
                  icon: Icons.calendar_today,
                  label: EventsStrings.detailsDate,
                  value:
                      '${_formatDate(event.startAt)} - ${_formatTime(event.endAt)}',
                ),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: EventsStrings.detailsLocation,
                  value: event.locationName,
                ),
                _InfoRow(
                  icon: Icons.person_outline,
                  label: EventsStrings.detailsHost,
                  value: event.hostName,
                ),
                _InfoRow(
                  icon: Icons.groups_outlined,
                  label: EventsStrings.detailsParticipants,
                  value: _participantsText(event),
                ),
                const SizedBox(height: PlayceSpacing.md),
                _StatusMessage(event: event, userId: userId),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(PlayceSpacing.md),
            child: SizedBox(
              width: double.infinity,
              child: _ActionButton(
                event: event,
                userId: userId,
                isJoined: isJoined,
                isHost: isHost,
                canJoin: canJoin,
                canLeave: canLeave,
                isLoading: isActionLoading,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _participantsText(Event event) {
    if (event.maxParticipants <= 0) {
      return '${event.participantCount} confirmados';
    }
    return '${event.participantCount}/${event.maxParticipants} confirmados';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString().padLeft(4, '0');
    final hour = _formatTime(date);
    return '$day/$month/$year $hour';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PlayceSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: PlayceColors.primary),
          const SizedBox(width: PlayceSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: PlayceColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: PlayceSpacing.xs),
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.event, required this.userId});

  final Event event;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final message = _message;
    if (message == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PlayceSpacing.md),
      decoration: BoxDecoration(
        color: PlayceColors.secondaryContainer,
        borderRadius: BorderRadius.circular(PlayceRadius.md),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: PlayceColors.onSecondaryContainer,
        ),
      ),
    );
  }

  String? get _message {
    if (event.hostId == userId) {
      return EventsStrings.detailsHostJoined;
    }
    if (event.isJoinedBy(userId)) {
      return EventsStrings.detailsAlreadyJoined;
    }
    if (event.isFull) {
      return EventsStrings.detailsFull;
    }
    return null;
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.event,
    required this.userId,
    required this.isJoined,
    required this.isHost,
    required this.canJoin,
    required this.canLeave,
    required this.isLoading,
  });

  final Event event;
  final String userId;
  final bool isJoined;
  final bool isHost;
  final bool canJoin;
  final bool canLeave;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isJoined) {
      return OutlinedButton.icon(
        onPressed: canLeave && !isLoading
            ? () => context.read<EventDetailsCubit>().leave(event, userId)
            : null,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.event_busy_outlined),
        label: Text(
          isHost ? EventsStrings.hostCannotLeave : EventsStrings.leave,
        ),
      );
    }

    return PlaycePrimaryButton(
      label: event.isFull ? EventsStrings.full : EventsStrings.join,
      icon: Icons.event_available_outlined,
      isLoading: isLoading,
      onPressed: canJoin
          ? () => context.read<EventDetailsCubit>().join(event, userId)
          : null,
    );
  }
}
