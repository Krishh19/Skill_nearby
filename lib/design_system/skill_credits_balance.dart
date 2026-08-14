import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Card showing user's skill-credit balance and monthly breakdown.
///
/// Concept: users earn credits by teaching skills and spend credits on learning.
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF074540)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadii.card,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
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
          const SizedBox(height: AppSpace.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$credits',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 6, bottom: 6),
                child: Text(
                  'credits available',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          Row(
            children: [
              _MiniStat(
                icon: Icons.arrow_upward,
                label: 'Earned',
                value: '+$earnedThisMonth',
                color: Colors.greenAccent.shade100,
              ),
              const SizedBox(width: AppSpace.sm),
              const _MiniStat(
                icon: Icons.arrow_downward,
                label: 'Spent',
                value: '-2',
                color: AppColors.softCoral,
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
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.sm,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
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
                    fontSize: 14,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
