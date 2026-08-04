import 'package:flutter/material.dart';

/// A card showing a user's skill-credit balance and recent activity.
///
/// Concept: instead of strict 1:1 swaps, users earn credits by teaching
/// and spend credits on any skill they want to learn — more flexible
/// than requiring a direct match every time.
class SkillCreditsBalance extends StatelessWidget {
  final int credits;
  final int earnedThisMonth;
  final int spentThisMonth;
  final VoidCallback? onHistoryTap;

  const SkillCreditsBalance({
    super.key,
    required this.credits,
    required this.earnedThisMonth,
    required this.spentThisMonth,
    this.onHistoryTap,
  });

  static const _teal = Color(0xFF0F6E5E);
  static const _tealDark = Color(0xFF0A4F43);
  static const _coral = Color(0xFFFF7A66);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_teal, _tealDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _teal.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Skill Credits',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: onHistoryTap,
                child: const Row(
                  children: [
                    Text(
                      'History',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    Icon(Icons.chevron_right, color: Colors.white70, size: 18),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$credits',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 6, bottom: 8),
                child: Text(
                  'credits',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _MiniStat(
                icon: Icons.arrow_upward,
                label: 'Earned',
                value: '+$earnedThisMonth',
                color: Colors.greenAccent.shade100,
              ),
              const SizedBox(width: 16),
              _MiniStat(
                icon: Icons.arrow_downward,
                label: 'Spent',
                value: '-$spentThisMonth',
                color: _coral,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// --- Example usage ---
/// SkillCreditsBalance(
///   credits: 8,
///   earnedThisMonth: 5,
///   spentThisMonth: 2,
///   onHistoryTap: () {},
/// );
