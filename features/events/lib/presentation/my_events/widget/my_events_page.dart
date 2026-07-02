import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:events/domain/model/event.dart';
import 'package:events/presentation/details/widget/event_details_page.dart';
import 'package:events/presentation/my_events/bloc/my_events_cubit.dart';
import 'package:events/presentation/my_events/bloc/my_events_state.dart';
import 'package:events/presentation/strings.dart';

class MyEventsPage extends StatefulWidget {
  const MyEventsPage({required this.userId, this.isWoman = false, super.key});

  final String userId;
  final bool isWoman;

  @override
  State<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  late final MyEventsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.I.get<MyEventsCubit>()..load(widget.userId);
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
      child: _MyEventsView(userId: widget.userId, isWoman: widget.isWoman),
    );
  }
}

class _MyEventsView extends StatelessWidget {
  const _MyEventsView({required this.userId, required this.isWoman});

  final String userId;
  final bool isWoman;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<MyEventsCubit, MyEventsState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: PlayceGradientHeader(
                    title: EventsStrings.myEventsTitle,
                    subtitle: EventsStrings.myEventsSubtitle,
                  ),
                ),
                switch (state) {
                  MyEventsInitialState() ||
                  MyEventsLoadingState() => const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  MyEventsErrorState(:final message) => SliverFillRemaining(
                    hasScrollBody: false,
                    child: PlayceEmptyState(
                      title: 'Ops!',
                      message: message,
                      icon: Icons.cloud_off_outlined,
                    ),
                  ),
                  MyEventsLoadedState(:final events) when events.isEmpty =>
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: PlayceEmptyState(
                        title: EventsStrings.myEventsEmptyTitle,
                        message: EventsStrings.myEventsEmptyMessage,
                        icon: Icons.event_busy_outlined,
                      ),
                    ),
                  MyEventsLoadedState(:final events) => SliverPadding(
                    padding: const EdgeInsets.all(PlayceSpacing.md),
                    sliver: SliverList.separated(
                      itemCount: events.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: PlayceSpacing.md),
                      itemBuilder: (context, index) {
                        return _MyEventCard(
                          event: events[index],
                          userId: userId,
                          isWoman: isWoman,
                        );
                      },
                    ),
                  ),
                },
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MyEventCard extends StatelessWidget {
  const _MyEventCard({
    required this.event,
    required this.userId,
    required this.isWoman,
  });

  final Event event;
  final String userId;
  final bool isWoman;

  @override
  Widget build(BuildContext context) {
    final isHost = event.hostId == userId;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(PlayceRadius.md),
        onTap: () => _openDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(PlayceSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: PlayceSpacing.sm,
                runSpacing: PlayceSpacing.xs,
                children: [
                  Chip(label: Text(sportTypeLabel(event.sportType))),
                  if (isHost)
                    const Chip(
                      avatar: Icon(Icons.star_outline, size: 16),
                      label: Text(EventsStrings.myEventsHostBadge),
                    ),
                  if (event.womenOnly)
                    const Chip(
                      avatar: Icon(Icons.female, size: 16),
                      label: Text(EventsStrings.womenOnlyBadge),
                    ),
                ],
              ),
              const SizedBox(height: PlayceSpacing.sm),
              Text(event.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: PlayceSpacing.sm),
              Text(
                event.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: PlayceColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: PlayceSpacing.md),
              _EventMetaRow(
                icon: Icons.calendar_today,
                text: _formatEventDate(event.startAt),
              ),
              const SizedBox(height: PlayceSpacing.xs),
              _EventMetaRow(
                icon: Icons.location_on_outlined,
                text: event.locationName,
              ),
              const SizedBox(height: PlayceSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${event.participantCount} confirmados',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: PlayceColors.tertiary,
                      ),
                    ),
                  ),
                  const SizedBox(width: PlayceSpacing.md),
                  FilledButton(
                    onPressed: () => _openDetails(context),
                    child: const Text(EventsStrings.detailsButton),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openDetails(BuildContext context) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            EventDetailsPage(event: event, userId: userId, isWoman: isWoman),
      ),
    );

    if (changed == true && context.mounted) {
      await context.read<MyEventsCubit>().load(userId);
    }
  }

  String _formatEventDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }
}

class _EventMetaRow extends StatelessWidget {
  const _EventMetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: PlayceSpacing.xs),
        Expanded(
          child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
