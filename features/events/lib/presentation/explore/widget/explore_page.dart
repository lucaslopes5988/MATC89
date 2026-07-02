import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:events/domain/model/event.dart';
import 'package:events/presentation/details/widget/event_details_page.dart';
import 'package:events/presentation/explore/bloc/explore_cubit.dart';
import 'package:events/presentation/explore/bloc/explore_state.dart';
import 'package:events/presentation/strings.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({
    required this.userId,
    this.isWoman = false,
    super.key,
  });

  final String userId;
  final bool isWoman;

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  late final ExploreCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.I.get<ExploreCubit>()
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
      child: _ExploreView(userId: widget.userId, isWoman: widget.isWoman),
    );
  }
}

class _ExploreView extends StatelessWidget {
  const _ExploreView({required this.userId, this.isWoman = false});

  final String userId;
  final bool isWoman;

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
        child: BlocBuilder<ExploreCubit, ExploreState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: PlayceGradientHeader(
                    title: EventsStrings.exploreTitle,
                    subtitle: EventsStrings.exploreSubtitle,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(PlayceSpacing.md),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: EventsStrings.searchHint,
                        prefixIcon: Icon(Icons.search),
                      ),
                      enabled: false,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 44,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: PlayceSpacing.md,
                      ),
                      child: Row(
                        children: [
                          for (int i = 0; i < _filters.length; i++) ...[
                            if (i > 0) const SizedBox(width: PlayceSpacing.sm),
                            Builder(
                              builder: (context) {
                                final sport = _filters[i];
                                final selected =
                                    state is ExploreLoadedState &&
                                    state.selectedSport == sport;
                                return FilterChip(
                                  label: Text(sportTypeLabel(sport)),
                                  selected: selected,
                                  onSelected: (_) => context
                                      .read<ExploreCubit>()
                                      .filterBySport(sport),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                switch (state) {
                  ExploreLoadingState() ||
                  ExploreInitialState() => const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  ExploreErrorState(:final message) => SliverFillRemaining(
                    hasScrollBody: false,
                    child: PlayceEmptyState(
                      title: 'Ops!',
                      message: message,
                      icon: Icons.cloud_off_outlined,
                    ),
                  ),
                  ExploreLoadedState(:final events) when events.isEmpty =>
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: PlayceEmptyState(
                        title: EventsStrings.emptyTitle,
                        message: EventsStrings.emptyMessage,
                      ),
                    ),
                  ExploreLoadedState(:final events) => SliverPadding(
                    padding: const EdgeInsets.all(PlayceSpacing.md),
                    sliver: SliverList.separated(
                      itemCount: events.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: PlayceSpacing.md),
                      itemBuilder: (context, index) {
                        return _EventCard(
                          event: events[index],
                          userId: userId,
                          selectedSport: state.selectedSport,
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

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.userId,
    required this.selectedSport,
    this.isWoman = false,
  });

  final Event event;
  final String userId;
  final SportType selectedSport;
  final bool isWoman;

  @override
  Widget build(BuildContext context) {
    final slots = event.slotsLeft;

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
                  if (event.womenOnly)
                    Chip(
                      avatar: const Icon(Icons.female, size: 16),
                      label: const Text(EventsStrings.womenOnlyBadge),
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
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: PlayceSpacing.xs),
                  Text(_formatEventDate(event.startAt)),
                ],
              ),
              const SizedBox(height: PlayceSpacing.xs),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16),
                  const SizedBox(width: PlayceSpacing.xs),
                  Expanded(child: Text(event.locationName)),
                ],
              ),
              const SizedBox(height: PlayceSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.isFull
                          ? EventsStrings.full
                          : slots == null
                          ? '${event.participantCount} inscritos'
                          : '$slots ${EventsStrings.slotsLeft}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: event.isFull
                            ? PlayceColors.error
                            : PlayceColors.tertiary,
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
        builder: (_) => EventDetailsPage(
          event: event,
          userId: userId,
          isWoman: isWoman,
        ),
      ),
    );

    if (changed == true && context.mounted) {
      final filter = selectedSport == SportType.all ? null : selectedSport;
      await context.read<ExploreCubit>().load(sportType: filter);
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
