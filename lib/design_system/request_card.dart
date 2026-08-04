import 'package:flutter/material.dart';

import '../domain/models.dart';
import 'app_theme.dart';

/// Redesigned request card widget.
///
/// Features:
/// - Single-line status pill and action labels ("Complete" with checkmark icon)
/// - Relative timestamp ("2h ago")
/// - Initial avatar rendering matching theme
/// - Equal-width icon-labelled action buttons
class RequestCardWidget extends StatelessWidget {
  const RequestCardWidget({
    super.key,
    required this.name,
    required this.initials,
    required this.skillOffered,
    required this.skillWanted,
    required this.status,
    required this.isPendingSync,
    required this.requestedAt,
    this.onMessage,
    this.onPrimaryAction,
  });

  final String name;
  final String initials;
  final String skillOffered;
  final String skillWanted;
  final RequestStatus status;
  final bool isPendingSync;
  final DateTime requestedAt;
  final VoidCallback? onMessage;
  final VoidCallback? onPrimaryAction;

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == RequestStatus.completed;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpace.sm),
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.card,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: avatar, name, timestamp, status pill
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.softGold,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: AppSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _timeAgo(requestedAt),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              _StatusPill(
                status: status,
                pending: isPendingSync,
              ),
            ],
          ),
          const SizedBox(height: AppSpace.sm),

          // Skill exchange row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: AppRadii.input,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    skillOffered,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    Icons.swap_horiz,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                Expanded(
                  child: Text(
                    skillWanted,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.sm),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onMessage,
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Message'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadii.pill,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpace.xs),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onPrimaryAction,
                  icon: Icon(
                    isCompleted ? Icons.star_border : Icons.check_circle_outline,
                    size: 18,
                  ),
                  label: Text(isCompleted ? 'Rate' : 'Complete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCompleted ? AppColors.primary : AppColors.accent,
                    foregroundColor: AppColors.surface,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadii.pill,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final RequestStatus status;
  final bool pending;

  const _StatusPill({required this.status, required this.pending});

  @override
  Widget build(BuildContext context) {
    final (label, color, background) = switch (status) {
      RequestStatus.pending => (
        'Pending',
        AppColors.warning,
        AppColors.softGold,
      ),
      RequestStatus.accepted => (
        'Accepted',
        AppColors.success,
        AppColors.softTeal,
      ),
      RequestStatus.completed => (
        'Completed',
        AppColors.primary,
        AppColors.softTeal,
      ),
      RequestStatus.declined => (
        'Declined',
        AppColors.accent,
        AppColors.softCoral,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadii.pill,
      ),
      child: Text(
        '${pending ? 'Queued · ' : ''}$label',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}
