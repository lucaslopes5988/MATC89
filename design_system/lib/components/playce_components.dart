import 'package:flutter/material.dart';

import '../theme/playce_theme.dart';

class PlaycePrimaryButton extends StatelessWidget {
  const PlaycePrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : icon == null
          ? Text(label)
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: PlayceSpacing.sm),
                Text(label),
              ],
            ),
    );
  }
}

class PlayceGradientHeader extends StatelessWidget {
  const PlayceGradientHeader({required this.title, this.subtitle, super.key});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PlayceSpacing.lg),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [PlayceColors.primary, PlayceColors.primaryContainer],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(PlayceRadius.lg),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: PlayceColors.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: PlayceSpacing.sm),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: PlayceColors.onPrimary.withValues(alpha: 0.9),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class PlayceEmptyState extends StatelessWidget {
  const PlayceEmptyState({
    required this.title,
    required this.message,
    this.icon = Icons.event_busy_outlined,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PlayceSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: PlayceColors.onSurfaceVariant),
            const SizedBox(height: PlayceSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: PlayceSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: PlayceColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
