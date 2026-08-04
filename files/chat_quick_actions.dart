import 'package:flutter/material.dart';

/// A horizontal row of quick-action chips shown above the chat input.
///
/// Lets users coordinate a swap without typing everything manually —
/// e.g. proposing a meeting time, sharing location, or confirming the swap.
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
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEDE7DA), width: 1)),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _QuickActionChip(
            icon: Icons.event_available,
            label: 'Propose meeting',
            onTap: onProposeMeeting,
          ),
          const SizedBox(width: 8),
          _QuickActionChip(
            icon: Icons.location_on_outlined,
            label: 'Share location',
            onTap: onShareLocation,
          ),
          const SizedBox(width: 8),
          _QuickActionChip(
            icon: Icons.handshake_outlined,
            label: 'Confirm swap',
            onTap: onConfirmSwap,
            filled: true,
          ),
        ],
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

  static const _teal = Color(0xFF0F6E5E);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? _teal : _teal.withOpacity(0.08),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: filled ? Colors.white : _teal),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: filled ? Colors.white : _teal,
                  fontWeight: FontWeight.w500,
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

/// --- Example usage: place above your message input in the chat screen ---
/// Column(
///   mainAxisSize: MainAxisSize.min,
///   children: [
///     ChatQuickActions(
///       onProposeMeeting: () => _showMeetingPicker(context),
///       onShareLocation: () => _shareCurrentLocation(),
///       onConfirmSwap: () => _confirmSwapDialog(context),
///     ),
///     MessageInputBar(), // your existing text field
///   ],
/// );
