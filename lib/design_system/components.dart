import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/revenue_cat_service.dart';
import '../domain/models.dart';
import 'app_theme.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isSecondary = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final IconData? icon;

  void _handlePress() {
    if (onPressed != null) {
      HapticFeedback.lightImpact();
      onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 52,
    child: isSecondary
        ? OutlinedButton.icon(
            onPressed: onPressed == null ? null : _handlePress,
            icon: icon == null ? const SizedBox.shrink() : Icon(icon),
            label: Text(label),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: const RoundedRectangleBorder(borderRadius: AppRadii.input),
            ),
          )
        : ElevatedButton.icon(
            onPressed: onPressed == null ? null : _handlePress,
            icon: icon == null ? const SizedBox.shrink() : Icon(icon),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
              shape: const RoundedRectangleBorder(borderRadius: AppRadii.input),
            ),
          ),
  );
}

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppSpace.md),
  });
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: const BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadii.card,
      boxShadow: AppShadows.card,
    ),
    child: child,
  );
}

class SkillChip extends StatelessWidget {
  const SkillChip({
    required this.label,
    super.key,
    this.level,
    this.selected = false,
    this.onDeleted,
  });
  final String label;
  final String? level;
  final bool selected;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: selected ? AppColors.primary : AppColors.softTeal,
      borderRadius: AppRadii.pill,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.surface : AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        if (level != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: level == 'Expert'
                  ? AppColors.primary
                  : level == 'Intermediate'
                      ? AppColors.accent
                      : AppColors.textSecondary.withOpacity(0.2),
              borderRadius: AppRadii.pill,
            ),
            child: Text(
              level!,
              style: TextStyle(
                color: level == 'Expert' || level == 'Intermediate'
                    ? Colors.white
                    : AppColors.textPrimary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
        if (onDeleted != null) ...[
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDeleted,
            child: Icon(
              Icons.close,
              size: 14,
              color: selected ? AppColors.surface : AppColors.primary,
            ),
          ),
        ],
      ],
    ),
  );
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({
    required this.connection,
    required this.pendingCount,
    super.key,
  });
  final AppConnectionState connection;
  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    if (connection == AppConnectionState.online && pendingCount == 0) {
      return const SizedBox.shrink();
    }
    final offline = connection == AppConnectionState.offline;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        AppSpace.md,
        AppSpace.sm,
        AppSpace.md,
        0,
      ),
      padding: const EdgeInsets.all(AppSpace.sm),
      decoration: BoxDecoration(
        color: offline ? AppColors.accent : AppColors.primary,
        borderRadius: AppRadii.input,
      ),
      child: Row(
        children: [
          Icon(
            offline ? Icons.cloud_off_rounded : Icons.cloud_done_rounded,
            color: AppColors.surface,
          ),
          const SizedBox(width: AppSpace.sm),
          Expanded(
            child: Text(
              offline
                  ? 'You’re offline. Showing your saved neighbourhood.'
                  : '$pendingCount action${pendingCount == 1 ? '' : 's'} syncing safely.',
              style: const TextStyle(
                color: AppColors.surface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FriendlyEmptyState extends StatelessWidget {
  const FriendlyEmptyState({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    super.key,
  });
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpace.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 38,
            backgroundColor: AppColors.softGold,
            child: Icon(
              Icons.volunteer_activism_outlined,
              color: AppColors.accent,
              size: 34,
            ),
          ),
          const SizedBox(height: AppSpace.md),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpace.xs),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: AppSpace.md),
          AppButton(label: actionLabel, onPressed: onAction),
        ],
      ),
    ),
  );
}

class SkillNearbyPlusPaywallSheet extends ConsumerWidget {
  const SkillNearbyPlusPaywallSheet({super.key});

  static void show(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const SkillNearbyPlusPaywallSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.lg),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpace.md),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.softGold,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star_rounded, color: AppColors.accent, size: 28),
              ),
              const SizedBox(width: AppSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SkillNearby Plus',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontSize: 22,
                      ),
                    ),
                    const Text('Unlock your full neighbourhood network', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          const _FeatureRow(icon: Icons.radar, title: '20 km Expanded Radius', subtitle: 'Search beyond 2 km to connect across your city'),
          const _FeatureRow(icon: Icons.all_inclusive, title: 'Unlimited Swaps & Standing Offers', subtitle: 'Post 24/7 offers and swap as often as you like'),
          const _FeatureRow(icon: Icons.savings_outlined, title: 'Skill Credits Banking', subtitle: 'Bank credits when teaching, spend on any skill later'),
          const _FeatureRow(icon: Icons.verified_user_outlined, title: 'Priority ID Verification', subtitle: 'Get a trusted neighbourhood badge on your profile'),
          const SizedBox(height: AppSpace.lg),
          Container(
            padding: const EdgeInsets.all(AppSpace.sm),
            decoration: BoxDecoration(
              color: AppColors.softTeal,
              borderRadius: AppRadii.input,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Plus Membership', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('Cancel anytime in store settings', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
                Text('\$4.99 / mo', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.md),
          AppButton(
            label: 'Start 7-Day Free Trial',
            onPressed: () async {
              final success = await ref.read(revenueCatServiceProvider).purchaseTestPlus();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? '🎉 SkillNearby Plus Activated! 20 km search radius unlocked.'
                          : 'SkillNearby Plus activation pending.',
                    ),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: AppSpace.xs),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue with Free Tier (2 km limit)', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.sm),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: AppSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
