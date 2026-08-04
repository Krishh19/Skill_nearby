import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Horizontal row of quick-action chips shown above the chat input.
///
/// Provides comfortable vertical breathing room between messages and composer
/// while maintaining safe-area compatibility.
class ChatQuickActions extends StatelessWidget {
  final VoidCallback? onProposeMeeting;
  final VoidCallback? onShareLocation;
  final VoidCallback? onConfirmSwap;

  const ChatQuickActions({
    super.key,
    this.onProposeMeeting,
    this.onShareLocation,
    this.onConfirmSwap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: AppSpace.sm),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SizedBox(
        height: 38,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _QuickActionChip(
              icon: Icons.event_available,
              label: 'Propose meeting',
              onTap: onProposeMeeting,
            ),
            const SizedBox(width: AppSpace.xs),
            _QuickActionChip(
              icon: Icons.location_on_outlined,
              label: 'Share location',
              onTap: onShareLocation,
            ),
            const SizedBox(width: AppSpace.xs),
            _QuickActionChip(
              icon: Icons.handshake_outlined,
              label: 'Confirm swap',
              onTap: onConfirmSwap,
              filled: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool filled;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.primary : AppColors.softTeal,
      borderRadius: AppRadii.pill,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.pill,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: filled ? AppColors.surface : AppColors.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: filled ? AppColors.surface : AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
