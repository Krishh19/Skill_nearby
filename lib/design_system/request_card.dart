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
    this.onUndoAccept,
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
  final VoidCallback? onUndoAccept;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? DarkColors.surface : AppColors.surface;
    final borderColor = isDark ? DarkColors.line : AppColors.border;
    final stripBg = isDark ? DarkColors.surface2 : AppColors.background;
    final primaryTextColor = isDark ? DarkColors.ink : AppColors.textPrimary;
    final secondaryTextColor = isDark ? DarkColors.stone : AppColors.textSecondary;
    final tealColor = isDark ? DarkColors.teal : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpace.sm),
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadii.card,
        boxShadow: isDark
            ? [
                const BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ]
            : AppShadows.card,
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: avatar, name, timeline, status pill
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: isDark ? DarkColors.surface2 : AppColors.softGold,
                child: Text(
                  initials,
                  style: TextStyle(
                    color: tealColor,
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
                        color: primaryTextColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _timelineText,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        color: secondaryTextColor,
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
              color: stripBg,
              borderRadius: AppRadii.input,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.swap_horiz_rounded,
                  size: 20,
                  color: isDark ? DarkColors.coral : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        color: primaryTextColor,
                        height: 1.35,
                      ),
                      children: [
                        TextSpan(
                          text: skillOffered,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text: '  for  ',
                          style: TextStyle(
                            color: secondaryTextColor,
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
          _buildActionRow(context),
        ],
      ),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBtnBg = isDark ? DarkColors.teal : AppColors.primary;
    final primaryBtnText = isDark ? const Color(0xFF0B1B17) : Colors.white;
    final accentBtnColor = isDark ? DarkColors.coral : AppColors.accent;
    final outlineBorderColor = isDark ? DarkColors.tealDeep : AppColors.primary;

    // 1. Incoming Pending: Decline + Accept
    if (status == RequestStatus.pending && isIncoming) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onDecline,
              style: OutlinedButton.styleFrom(
                foregroundColor: accentBtnColor,
                side: BorderSide(color: accentBtnColor),
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
                backgroundColor: primaryBtnBg,
                foregroundColor: primaryBtnText,
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
            foregroundColor: primaryBtnBg,
            side: BorderSide(color: outlineBorderColor),
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
                foregroundColor: primaryBtnBg,
                side: BorderSide(color: outlineBorderColor),
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
                backgroundColor: primaryBtnBg,
                foregroundColor: primaryBtnText,
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
          if (onUndoAccept != null || onDecline != null)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, size: 20, color: isDark ? DarkColors.stone : AppColors.textSecondary),
              tooltip: 'More options',
              onSelected: (val) {
                if (val == 'undo') {
                  (onUndoAccept ?? onDecline)?.call();
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'undo',
                  child: Row(
                    children: [
                      Icon(Icons.undo_rounded, size: 18, color: accentBtnColor),
                      const SizedBox(width: 8),
                      Text('Undo Accept', style: TextStyle(color: accentBtnColor, fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
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
              foregroundColor: primaryBtnBg,
              side: BorderSide(color: outlineBorderColor),
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
              foregroundColor: Colors.black,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (label, color, background) = switch (status) {
      RequestStatus.pending => (
        'PENDING',
        isDark ? DarkColors.coral : AppColors.accent,
        isDark ? const Color(0xFF3B2620) : AppColors.softCoral,
      ),
      RequestStatus.accepted => (
        'ACCEPTED',
        isDark ? DarkColors.teal : AppColors.success,
        isDark ? const Color(0xFF1D3B34) : AppColors.softTeal,
      ),
      RequestStatus.completed => (
        'COMPLETED',
        isDark ? DarkColors.teal : AppColors.primary,
        isDark ? const Color(0xFF1D3B34) : AppColors.softTeal,
      ),
      RequestStatus.declined => (
        'DECLINED',
        isDark ? DarkColors.coral : AppColors.accent,
        isDark ? const Color(0xFF3B2620) : AppColors.softCoral,
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
