import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components.dart';

class RatingReviewScreen extends ConsumerStatefulWidget {
  const RatingReviewScreen({required this.requestId, super.key});
  final String requestId;

  @override
  ConsumerState<RatingReviewScreen> createState() => _RatingReviewScreenState();
}

class _RatingReviewScreenState extends ConsumerState<RatingReviewScreen> {
  double _rating = 5.0;
  final TextEditingController _commentController = TextEditingController();
  final Set<String> _selectedTags = {'Patient Teacher', 'Punctual'};

  final List<String> _availableTags = const [
    'Patient Teacher',
    'Punctual',
    'Great Communicator',
    'Generous',
    'Fun Session',
    'Super Skilled',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Swap Session'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Skill Credits Reward Banner
              Container(
                padding: const EdgeInsets.all(AppSpace.md),
                decoration: BoxDecoration(
                  color: AppColors.softGold,
                  borderRadius: AppRadii.card,
                  border: Border.all(color: AppColors.warning.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.stars, color: AppColors.warning, size: 28),
                    ),
                    const SizedBox(width: AppSpace.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '+3 Skill Credits Earned!',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Your credits balance has been updated. You can spend credits on any skill!',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.lg),

              // Rating Header
              Text(
                'How was your session with your neighbour?',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpace.md),

              // Interactive 5-Star Rating Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starValue = index + 1.0;
                  final isFilled = starValue <= _rating;
                  return IconButton(
                    iconSize: 40,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() => _rating = starValue);
                    },
                    icon: Icon(
                      isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: isFilled ? AppColors.warning : AppColors.border,
                    ),
                  );
                }),
              ),
              Center(
                child: Text(
                  '${_rating.toStringAsFixed(1)} Out of 5.0 Stars',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: AppSpace.lg),

              // Feedback Tags Selector
              const Text('Highlight key qualities:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: AppSpace.xs),
              Wrap(
                spacing: AppSpace.xs,
                runSpacing: AppSpace.xs,
                children: _availableTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    onSelected: (selected) {
                      HapticFeedback.lightImpact();
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpace.lg),

              // Review / Testimonial Text Field
              TextField(
                controller: _commentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Leave a kind word (Optional)',
                  hintText: 'Share a brief testimonial about your experience to help foster neighbourhood trust…',
                ),
              ),
              const SizedBox(height: AppSpace.xl),

              // Submit Review Button
              AppButton(
                label: 'Submit Review & Claim Credits',
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  await ref.read(repositoryProvider).submitSwapRating(
                        requestId: widget.requestId,
                        rating: _rating,
                        comment: _commentController.text.trim(),
                        tags: _selectedTags.toList(),
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('🎉 Review submitted! +3 Skill Credits added.')),
                    );
                    context.go('/nearby');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
