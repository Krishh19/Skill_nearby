import 'package:flutter/material.dart';

/// Status of a swap request.
enum RequestStatus { pending, completed }

/// A single skill-swap request between two users.
class SwapRequest {
  final String name;
  final String initials;
  final String skillOffered;
  final String skillWanted;
  final RequestStatus status;
  final DateTime requestedAt;

  const SwapRequest({
    required this.name,
    required this.initials,
    required this.skillOffered,
    required this.skillWanted,
    required this.status,
    required this.requestedAt,
  });
}

/// Redesigned request card.
///
/// Fixes vs. the original mock:
/// - Status pill no longer wraps ("Mark complete" -> "Complete")
/// - Adds a relative timestamp so users can gauge urgency
/// - Avatar uses initials consistently (no placeholder icons)
/// - Action buttons are equal-width and icon-labelled
class RequestCard extends StatelessWidget {
  final SwapRequest request;
  final VoidCallback? onMessage;
  final VoidCallback? onPrimaryAction; // "Complete" or "Rate"

  const RequestCard({
    super.key,
    required this.request,
    this.onMessage,
    this.onPrimaryAction,
  });

  static const _cream = Color(0xFFFAF6EE);
  static const _teal = Color(0xFF0F6E5E);
  static const _amber = Color(0xFFF5A623);
  static const _navy = Color(0xFF1E2A38);

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = request.status == RequestStatus.completed;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: avatar, name, timestamp, status pill
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: _amber.withOpacity(0.25),
                child: Text(
                  request.initials,
                  style: const TextStyle(
                    color: _teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _navy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _timeAgo(request.requestedAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: _navy.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              _StatusPill(
                label: isCompleted ? 'Completed' : 'Pending',
                color: isCompleted ? _teal : _amber,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Skill exchange row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _cream,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    request.skillOffered,
                    style: const TextStyle(color: _navy),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.swap_horiz, size: 18, color: _navy.withOpacity(0.4)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    request.skillWanted,
                    textAlign: TextAlign.end,
                    style: const TextStyle(color: _navy),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onMessage,
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Message'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _teal,
                    side: BorderSide(color: _teal.withOpacity(0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onPrimaryAction,
                  icon: Icon(
                    isCompleted
                        ? Icons.star_border
                        : Icons.check_circle_outline,
                    size: 18,
                  ),
                  label: Text(isCompleted ? 'Rate' : 'Complete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCompleted ? _navy : _teal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
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
  final String label;
  final Color color;
  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// --- Example usage ---
/// ListView(
///   children: [
///     RequestCard(
///       request: SwapRequest(
///         name: 'Rohan Verma',
///         initials: 'RV',
///         skillOffered: 'Graphic Design',
///         skillWanted: 'Guitar Lessons',
///         status: RequestStatus.pending,
///         requestedAt: DateTime.now().subtract(const Duration(hours: 2)),
///       ),
///       onMessage: () {},
///       onPrimaryAction: () {},
///     ),
///   ],
/// );
