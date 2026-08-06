import 'package:flutter/material.dart';

import '../domain/models.dart';
import 'app_theme.dart';

/// Redesigned request card widget.
///
/// Features:
/// - Direction-aware status actions (Pending Incoming -> Accept / Decline)
/// - Flexible skill exchange box wrapping without ugly text truncation
/// - Responsive equal-flex action buttons eliminating overflow
/// - Clear activity timeline indicator
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
    this.isIncoming = true,
    this.onMessage,
    this.onAccept,
    this.onDecline,
    this.onComplete,
    this.onRate,
    this.onPrimaryAction,
  });

  final String name;
  final String initials;
  final String skillOffered;
  final String skillWanted;
  final RequestStatus status;
  final bool isPendingSync;
  final DateTime requestedAt;
  final bool isIncoming;
  final VoidCallback? onMessage;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onComplete;
  final VoidCallback? onRate;
  final VoidCallback? onPrimaryAction;

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  String get _timelineText {
    final ago = _timeAgo(requestedAt);
    return switch (status) {
      RequestStatus.pending => isIncoming
          ? '$ago · Needs your response'
          : '$ago · Awaiting neighbour response',
      RequestStatus.accepted => '$ago · Swap in progress',
      RequestStatus.completed => '$ago · Completed',
      RequestStatus.declined => '$ago · Declined',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpace.sm),
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.card,
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: avatar, name, timeline, status pill
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.softGold,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
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
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _timelineText,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              _StatusPill(
                status: status,
                pending: isPendingSync,
              ),
            ],
          ),
          const SizedBox(height: AppSpace.sm),

          // Skill exchange container with proper wrapping
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: AppRadii.input,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.swap_horiz_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                      children: [
                        TextSpan(
                          text: skillOffered,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(
                          text: '  for  ',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextSpan(
                          text: skillWanted,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.sm),

          // Action Buttons according to status and direction
          _buildActionRow(),
        ],
      ),
    );
  }

  Widget _buildActionRow() {
    // 1. Incoming Pending: Decline + Accept
    if (status == RequestStatus.pending && isIncoming) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onDecline,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: const BorderSide(color: AppColors.accent),
                padding: const EdgeInsets.symmetric(vertical: 10),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadii.input,
                ),
              ),
              child: const Text('Decline', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ),
          const SizedBox(width: AppSpace.xs),
          Expanded(
            child: ElevatedButton(
              onPressed: onAccept ?? onPrimaryAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadii.input,
                ),
              ),
              child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ),
        ],
      );
    }

    // 2. Outgoing Pending: Message
    if (status == RequestStatus.pending && !isIncoming) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onMessage,
          icon: const Icon(Icons.chat_bubble_outline, size: 16),
          label: const Text('Message', style: TextStyle(fontSize: 13)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(vertical: 10),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadii.input,
            ),
          ),
        ),
      );
    }

    // 3. Accepted / Active: Message + Complete
    if (status == RequestStatus.accepted) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onMessage,
              icon: const Icon(Icons.chat_bubble_outline, size: 16),
              label: const Text('Message', style: TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 10),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadii.input,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpace.xs),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onComplete ?? onPrimaryAction,
              icon: const Icon(Icons.check_circle_outline, size: 16),
              label: const Text('Complete', style: TextStyle(fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadii.input,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // 4. Completed: Message + Rate
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onMessage,
            icon: const Icon(Icons.chat_bubble_outline, size: 16),
            label: const Text('Message', style: TextStyle(fontSize: 13)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 10),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadii.input,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpace.xs),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onRate ?? onPrimaryAction,
            icon: const Icon(Icons.star_outline, size: 16),
            label: const Text('Rate Swap', style: TextStyle(fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 10),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadii.input,
              ),
            ),
          ),
        ),
      ],
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
        'PENDING',
        AppColors.accent,
        AppColors.softCoral,
      ),
      RequestStatus.accepted => (
        'ACCEPTED',
        AppColors.success,
        AppColors.softTeal,
      ),
      RequestStatus.completed => (
        'COMPLETED',
        AppColors.primary,
        AppColors.softTeal,
      ),
      RequestStatus.declined => (
        'DECLINED',
        AppColors.accent,
        AppColors.softCoral,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadii.pill,
      ),
      child: Text(
        '${pending ? 'Queued · ' : ''}$label',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
