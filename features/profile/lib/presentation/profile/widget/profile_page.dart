import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:profile/domain/model/gender_identity.dart';
import 'package:profile/presentation/profile/bloc/profile_cubit.dart';
import 'package:profile/presentation/profile/bloc/profile_state.dart';
import 'package:profile/presentation/strings.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    required this.userId,
    required this.email,
    required this.onSignOut,
    this.displayName,
    this.photoUrl,
    super.key,
  });

  final String userId;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I.get<ProfileCubit>()..load(userId),
      child: _ProfileView(
        userId: userId,
        email: email,
        displayName: displayName,
        photoUrl: photoUrl,
        onSignOut: onSignOut,
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({
    required this.userId,
    required this.email,
    required this.onSignOut,
    this.displayName,
    this.photoUrl,
  });

  final String userId;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoadedState && state.message != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message!)));
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(PlayceSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _UserHeader(
                  displayName: displayName,
                  email: email,
                  photoUrl: photoUrl,
                ),
                const SizedBox(height: PlayceSpacing.xl),
                _GenderIdentitySection(state: state, userId: userId),
                const Spacer(),
                PlaycePrimaryButton(
                  label: ProfileStrings.signOut,
                  icon: Icons.logout,
                  onPressed: onSignOut,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader({
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  final String email;
  final String? displayName;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundImage:
              photoUrl != null ? NetworkImage(photoUrl!) : null,
          child: photoUrl == null ? const Icon(Icons.person) : null,
        ),
        const SizedBox(width: PlayceSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName ?? 'Atleta',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                email,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: PlayceColors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GenderIdentitySection extends StatelessWidget {
  const _GenderIdentitySection({
    required this.state,
    required this.userId,
  });

  final ProfileState state;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final isLoading =
        state is ProfileLoadingState || state is ProfileActionLoadingState;
    final currentIdentity = switch (state) {
      ProfileLoadedState(:final profile) => profile.genderIdentity,
      ProfileActionLoadingState(:final profile) => profile.genderIdentity,
      _ => null,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ProfileStrings.genderIdentityLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: PlayceSpacing.xs),
        Text(
          ProfileStrings.genderIdentityHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: PlayceColors.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: PlayceSpacing.md),
        if (state is ProfileLoadingState)
          const Center(child: CircularProgressIndicator())
        else if (state is ProfileErrorState)
          PlayceEmptyState(
            title: 'Ops!',
            message: (state as ProfileErrorState).message,
            icon: Icons.cloud_off_outlined,
          )
        else
          Wrap(
            spacing: PlayceSpacing.sm,
            runSpacing: PlayceSpacing.sm,
            children: [
              for (final identity in GenderIdentity.values)
                ChoiceChip(
                  label: Text(genderIdentityLabel(identity)),
                  selected: currentIdentity == identity,
                  onSelected: isLoading
                      ? null
                      : (_) {
                          final newValue =
                              currentIdentity == identity ? null : identity;
                          context.read<ProfileCubit>().updateGenderIdentity(
                                userId: userId,
                                genderIdentity: newValue,
                              );
                        },
                ),
            ],
          ),
      ],
    );
  }
}
