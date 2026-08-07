import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../data/notification_service.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components.dart';
import '../../design_system/request_card.dart';
import '../../design_system/skill_credits_balance.dart';
import '../../domain/models.dart';

class NearbyScreen extends ConsumerStatefulWidget {
  const NearbyScreen({super.key});
  @override
  ConsumerState<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends ConsumerState<NearbyScreen> {
  bool showMap = false;
  String query = '';
  String selectedCategory = 'All';

  final List<String> categories = const [
    'All',
    'Music',
    'Design',
    'Wellness',
    'Cooking',
    'Fixes',
  ];

  late final List<GlobalKey> _chipKeys;

  @override
  void initState() {
    super.initState();
    _chipKeys = List.generate(categories.length, (_) => GlobalKey());
  }

  void _showRadiusSelector(BuildContext context, WidgetRef ref, int currentRadius) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpace.lg,
            AppSpace.lg,
            AppSpace.lg,
            AppSpace.lg + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.near_me_outlined, color: AppColors.primary, size: 26),
                  const SizedBox(width: AppSpace.sm),
                  Text(
                    'Search Radius',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.xs),
              const Text('Choose how far you are willing to travel for a skill swap:'),
              const SizedBox(height: AppSpace.md),
              ...[1, 2, 5, 10].map((radius) {
                final isSelected = radius == currentRadius;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                  title: Row(
                    children: [
                      Text('$radius km radius'),
                      if (radius > 2) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: const BoxDecoration(
                            color: AppColors.softCoral,
                            borderRadius: AppRadii.pill,
                          ),
                          child: const Text('PLUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accent)),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    radius == 1 ? 'Walking distance (~12 mins)' : radius == 2 ? 'Short cycle (~8 mins)' : 'Short drive (SkillNearby Plus required)',
                  ),
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    if (radius > 2) {
                      Navigator.pop(context);
                      SkillNearbyPlusPaywallSheet.show(context);
                    } else {
                      await ref.read(repositoryProvider).setRadius(radius);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(profilesProvider);
    final preferences = ref.watch(preferencesProvider).value;
    final radiusKm = preferences?.radiusKm ?? 2;

    return PageFrame(
      title: 'Nearby skills',
      subtitleWidget: InkWell(
        onTap: () => _showRadiusSelector(context, ref, radiusKm),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Within $radiusKm km of your saved area',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, color: AppColors.primary, size: 20),
            ],
          ),
        ),
      ),
      child: profiles.when(
        loading: () => const _LoadingCards(),
        error: (_, __) => FriendlyEmptyState(
          title: 'We lost the trail',
          message:
              'Your saved profiles are safe. Try again when you reconnect.',
          actionLabel: 'Try again',
          onAction: () => ref.invalidate(profilesProvider),
        ),
        data: (items) {
          final matches = items.where((profile) {
            final matchesQuery =
                profile.name.toLowerCase().contains(query.toLowerCase()) ||
                profile.offers.any(
                  (skill) => skill.toLowerCase().contains(query.toLowerCase()),
                );
            if (!matchesQuery) return false;
            if (selectedCategory == 'All') return true;

            final cat = selectedCategory.toLowerCase();
            return profile.offers.any((offer) {
              final lower = offer.toLowerCase();
              if (cat == 'music') return lower.contains('guitar') || lower.contains('music') || lower.contains('ukulele');
              if (cat == 'design') return lower.contains('video') || lower.contains('editing') || lower.contains('adobe') || lower.contains('sketch');
              if (cat == 'wellness') return lower.contains('yoga') || lower.contains('meditation') || lower.contains('wellness');
              if (cat == 'cooking') return lower.contains('baking') || lower.contains('cooking') || lower.contains('meal');
              if (cat == 'fixes') return lower.contains('repair') || lower.contains('furniture') || lower.contains('tool');
              return true;
            });
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                onChanged: (value) => setState(() => query = value),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search skills or people',
                  border: OutlineInputBorder(
                    borderRadius: AppRadii.pill,
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadii.pill,
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadii.pill,
                    borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
              const SizedBox(height: AppSpace.sm),

              // Category filter chips with smooth auto-scroll on tap
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppSpace.xs),
                  itemBuilder: (_, index) {
                    final cat = categories[index];
                    final isSelected = selectedCategory == cat;
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    final chipBg = isSelected
                        ? (isDark ? DarkColors.teal : AppColors.primary)
                        : (isDark ? DarkColors.surface : AppColors.surface);
                    final chipText = isSelected
                        ? (isDark ? const Color(0xFF0B1B17) : Colors.white)
                        : (isDark ? DarkColors.ink : AppColors.textPrimary);
                    final chipBorder = isSelected
                        ? (isDark ? DarkColors.teal : AppColors.primary)
                        : (isDark ? DarkColors.line : AppColors.border);

                    return KeyedSubtree(
                      key: _chipKeys[index],
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: isDark ? DarkColors.teal : AppColors.primary,
                        backgroundColor: chipBg,
                        labelStyle: TextStyle(
                          color: chipText,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        side: BorderSide(color: chipBorder),
                        onSelected: (_) {
                          HapticFeedback.lightImpact();
                          setState(() => selectedCategory = cat);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            final ctx = _chipKeys[index].currentContext;
                            if (ctx != null) {
                              Scrollable.ensureVisible(
                                ctx,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpace.sm),

              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: false,
                    label: Text('List'),
                    icon: Icon(Icons.format_list_bulleted),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text('Map'),
                    icon: Icon(Icons.map_outlined),
                  ),
                ],
                selected: {showMap},
                onSelectionChanged: (value) {
                  HapticFeedback.lightImpact();
                  setState(() => showMap = value.first);
                },
              ),
              const SizedBox(height: AppSpace.md),
              if (showMap)
                _NearbyMapCanvas(profiles: matches)
              else if (matches.isEmpty || ref.watch(debugForceEmptyStatesProvider))
                FriendlyEmptyState(
                  imageAsset: query.isNotEmpty
                      ? 'assets/illustrations/empty/empty_search.png'
                      : (selectedCategory != 'All'
                          ? 'assets/illustrations/empty/empty_radius.png'
                          : 'assets/illustrations/empty/empty_nearby.png'),
                  title: query.isNotEmpty
                      ? 'No matches for "$query"'
                      : (selectedCategory != 'All'
                          ? 'No $selectedCategory skills nearby'
                          : 'No neighbours nearby yet'),
                  message: query.isNotEmpty
                      ? 'Try searching for a broader term like "Guitar", "Design", or "Baking".'
                      : (selectedCategory != 'All'
                          ? 'Try expanding your distance radius or switching category filters.'
                          : 'Be the first to share your skills in your saved area or invite local neighbours.'),
                  actionLabel: 'Reset filters',
                  onAction: () => setState(() {
                    query = '';
                    selectedCategory = 'All';
                  }),
                )
              else ...[
                ...matches.map(
                  (profile) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpace.sm),
                    child: ProfileCard(profile: profile),
                  ),
                ),
                const SizedBox(height: AppSpace.xs),
                AppCard(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/illustrations/empty/empty_invite.png',
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: AppSpace.xs),
                      const Text(
                        'Invite Local Neighbours',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Skill Nearby grows with your community. Invite friends & neighbours nearby to start swapping skills!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSpace.md),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('📲 Invite link copied to clipboard! Share with nearby friends.')),
                            );
                          },
                          icon: const Icon(Icons.share_outlined, size: 16),
                          label: const Text('Share Invite Link'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _NearbyMapCanvas extends StatefulWidget {
  const _NearbyMapCanvas({required this.profiles});
  final List<SkillProfile> profiles;

  @override
  State<_NearbyMapCanvas> createState() => _NearbyMapCanvasState();
}

class _NearbyMapCanvasState extends State<_NearbyMapCanvas> {
  SkillProfile? selectedProfile;
  double zoomScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Container(
        height: 340,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFFEFF7F5),
          borderRadius: AppRadii.card,
        ),
        child: Stack(
          children: [
            // Rich Vector Map Painter
            Transform.scale(
              scale: zoomScale,
              child: CustomPaint(
                size: const Size(double.infinity, 340),
                painter: _MapVectorPainter(),
              ),
            ),

            // Top-Left Status Badge
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadii.pill,
                  boxShadow: AppShadows.card,
                ),
                child: Row(
                  children: const [
                    Icon(Icons.location_on, size: 14, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text(
                      '📍 Indiranagar Neighbourhood Map',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),

            // Top-Right Zoom & Control Buttons
            Positioned(
              top: 12,
              right: 12,
              child: Column(
                children: [
                  _MapControlButton(
                    icon: Icons.add,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => zoomScale = (zoomScale + 0.15).clamp(0.8, 1.6));
                    },
                  ),
                  const SizedBox(height: 6),
                  _MapControlButton(
                    icon: Icons.remove,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => zoomScale = (zoomScale - 0.15).clamp(0.8, 1.6));
                    },
                  ),
                  const SizedBox(height: 6),
                  _MapControlButton(
                    icon: Icons.my_location,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        zoomScale = 1.0;
                        selectedProfile = null;
                      });
                    },
                  ),
                ],
              ),
            ),

            // User Location Marker (Center Pulsing Dot)
            Positioned(
              left: 170,
              top: 150,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2.5)),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'You',
                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Interactive Neighbour Profile Map Pins
            ...widget.profiles.asMap().entries.map((entry) {
              final idx = entry.key;
              final profile = entry.value;
              final positions = const [
                Offset(55, 75),
                Offset(220, 70),
                Offset(110, 195),
                Offset(245, 205),
                Offset(60, 245),
              ];
              final pos = positions[idx % positions.length];
              final isSelected = selectedProfile?.id == profile.id;

              return Positioned(
                left: pos.dx,
                top: pos.dy,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => selectedProfile = isSelected ? null : profile);
                  },
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.accent : AppColors.primary,
                          borderRadius: AppRadii.pill,
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: AppShadows.card,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 9,
                              backgroundColor: AppColors.softGold,
                              child: Text(
                                profile.initials,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 8,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              profile.offers.isNotEmpty ? profile.offers.first : profile.name,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '★${profile.rating}',
                              style: const TextStyle(color: Colors.white70, fontSize: 9),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: isSelected ? AppColors.accent : AppColors.primary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              );
            }),

            // Selected Profile Floating Preview Card
            if (selectedProfile != null)
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(AppSpace.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadii.card,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    boxShadow: AppShadows.card,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.softGold,
                        child: Text(
                          selectedProfile!.initials,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: AppSpace.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(selectedProfile!.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(
                              '${selectedProfile!.distanceKm} km away • Teaches ${selectedProfile!.offers.first}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => context.push('/request/${selectedProfile!.id}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: const RoundedRectangleBorder(borderRadius: AppRadii.pill),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Swap'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: AppShadows.card,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }
}

class _MapVectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Water River Body Stream Path
    final riverPaint = Paint()
      ..color = const Color(0xFFC4E8E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;

    final riverPath = Path()
      ..moveTo(0, size.height * 0.2)
      ..cubicTo(
        size.width * 0.35, size.height * 0.15,
        size.width * 0.55, size.height * 0.45,
        size.width, size.height * 0.35,
      );
    canvas.drawPath(riverPath, riverPaint);

    // 2. Green Neighbourhood Parks
    final parkPaint = Paint()
      ..color = const Color(0xFFE2F3E7)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.55, size.height * 0.55, 110, 80),
        const Radius.circular(16),
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.08, size.height * 0.65, 80, 60),
        const Radius.circular(12),
      ),
      parkPaint,
    );

    // 3. Secondary Streets
    final secondaryRoadPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    for (var y = 40.0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), secondaryRoadPaint);
    }
    for (var x = 50.0; x < size.width; x += 70) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), secondaryRoadPaint);
    }

    // 4. Main Avenues
    final mainRoadPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final mainRoadBorderPaint = Paint()
      ..color = const Color(0xFFD4E5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    // Diagonal Main Boulevard
    final boulevard = Path()
      ..moveTo(0, size.height * 0.8)
      ..lineTo(size.width, size.height * 0.1);

    canvas.drawPath(boulevard, mainRoadBorderPaint);
    canvas.drawPath(boulevard, mainRoadPaint);

    // Vertical Central Parkway
    canvas.drawLine(
      Offset(size.width * 0.48, 0),
      Offset(size.width * 0.48, size.height),
      mainRoadBorderPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.48, 0),
      Offset(size.width * 0.48, size.height),
      mainRoadPaint,
    );

    // 5. Landmark Text Labels
    const textStyle = TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF5A7B75));
    
    _drawText(canvas, '🏞️ Central Park', Offset(size.width * 0.58, size.height * 0.62), textStyle);
    _drawText(canvas, '🚇 Metro Station', Offset(size.width * 0.12, size.height * 0.12), textStyle);
    _drawText(canvas, '📚 Community Library', Offset(size.width * 0.52, size.height * 0.35), textStyle);
  }

  void _drawText(Canvas canvas, String text, Offset position, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({required this.profile, super.key});
  final SkillProfile profile;

  void _showVerificationDetails(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpace.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified, color: AppColors.primary, size: 28),
                const SizedBox(width: AppSpace.sm),
                Text(
                  'Verified Neighbour',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: AppSpace.sm),
            Text(
              '${profile.name} has completed identity verification to foster neighbourhood trust:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpace.md),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.check_circle, color: AppColors.success),
              title: Text('Phone number verified'),
            ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.check_circle, color: AppColors.success),
              title: Text('Government ID / Address check'),
            ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.check_circle, color: AppColors.success),
              title: Text('Positive neighbour ratings (4.5+ ★)'),
            ),
            const SizedBox(height: AppSpace.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => context.push('/profiles/${profile.id}'),
          borderRadius: AppRadii.card,
          child: Row(
            children: [
              Stack(
                children: [
                  ProfileAvatar(profile: profile),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (profile.isVerified)
                          GestureDetector(
                            onTap: () => _showVerificationDetails(context),
                            child: const Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: Tooltip(
                                message: 'Verified Neighbour',
                                child: Icon(
                                  Icons.verified,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        Text(
                          'Active ${((profile.id.hashCode.abs() % 15) + 2)}m ago',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.success, fontWeight: FontWeight.w600),
                        ),
                        const Text('•', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        Text(
                          '${profile.distanceKm.toStringAsFixed(1)} km away',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                        const Text('•', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        Text(
                          '★ ${profile.rating.toStringAsFixed(1)}',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.sm),
        if (profile.id == 'p1' || profile.offers.length > 2)
          Builder(
            builder: (ctx) {
              final isDark = Theme.of(ctx).brightness == Brightness.dark;
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpace.xs),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF332B18) : AppColors.softGold,
                  borderRadius: AppRadii.pill,
                  border: Border.all(color: isDark ? const Color(0xFF665322) : AppColors.warning.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt, color: AppColors.warning, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Standing Offer: Open to all requests',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFFFD580) : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        Wrap(
          spacing: AppSpace.xs,
          runSpacing: AppSpace.xs,
          children: profile.offers
              .take(3)
              .map((skill) => SkillChip(label: skill))
              .toList(),
        ),
        const SizedBox(height: AppSpace.sm),
        AppButton(
          label: 'Request swap',
          onPressed: () => context.push('/request/${profile.id}'),
        ),
      ],
    ),
  );
}

class RequestsScreen extends ConsumerStatefulWidget {
  const RequestsScreen({super.key});
  @override
  ConsumerState<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends ConsumerState<RequestsScreen> {
  int selected = 0;

  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Requests',
    child: ref
        .watch(requestsProvider)
        .when(
          loading: () => const _LoadingCards(),
          error: (_, __) => FriendlyEmptyState(
            title: 'Requests are taking a breather',
            message:
                'Your saved activity will return when the connection does.',
            actionLabel: 'Try again',
            onAction: () => ref.invalidate(requestsProvider),
          ),
          data: (requests) {
            final incomingCount = requests.where((item) => item.isIncoming).length;
            final outgoingCount = requests.where((item) => !item.isIncoming && item.status != RequestStatus.completed).length;
            final completedCount = requests.where((item) => item.status == RequestStatus.completed).length;

            final tabLabels = [
              'Incoming ($incomingCount)',
              'Outgoing ($outgoingCount)',
              'Completed ($completedCount)',
            ];

            final visible = switch (selected) {
              0 => requests.where((item) => item.isIncoming).toList(),
              1 =>
                requests
                    .where(
                      (item) =>
                          !item.isIncoming &&
                          item.status != RequestStatus.completed,
                    )
                    .toList(),
              _ =>
                requests
                    .where((item) => item.status == RequestStatus.completed)
                    .toList(),
            };

            return Column(
              children: [
                Container(
                  height: 44,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadii.pill,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: List.generate(tabLabels.length, (index) {
                      final isSelected = selected == index;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() => selected = index);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.accent : Colors.transparent,
                              borderRadius: AppRadii.pill,
                            ),
                            child: Text(
                              tabLabels[index],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isSelected ? AppColors.surface : AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: AppSpace.md),
                if (visible.isEmpty || ref.watch(debugForceEmptyStatesProvider))
                  switch (selected) {
                    0 => FriendlyEmptyState(
                        imageAsset: 'assets/illustrations/empty/empty_requests .png',
                        title: 'No incoming requests yet',
                        message:
                            'When neighbours reach out to trade skills with you, they will show up here.',
                        actionLabel: 'Explore nearby',
                        onAction: () => context.go('/nearby'),
                      ),
                    1 => FriendlyEmptyState(
                        imageAsset: 'assets/illustrations/empty/empty_requests .png',
                        title: 'No outgoing requests',
                        message:
                            'Browse nearby skills and start a new swap request with a neighbour.',
                        actionLabel: 'Find people',
                        onAction: () => context.go('/nearby'),
                      ),
                    _ => FriendlyEmptyState(
                        imageAsset: 'assets/illustrations/empty/empty_history.png',
                        title: 'No completed swaps yet',
                        message:
                            'Completed skill exchanges and mutual ratings will be stored here.',
                        actionLabel: 'Explore nearby',
                        onAction: () => context.go('/nearby'),
                      ),
                  }
                else
                  ...visible.map((request) {
                    final profile = ref
                        .read(repositoryProvider)
                        .profile(request.profileId);
                    return RequestCardWidget(
                      name: profile.name,
                      initials: profile.initials,
                      skillOffered: request.offeredSkill,
                      skillWanted: request.wantedSkill,
                      status: request.status,
                      isPendingSync: request.isPendingSync,
                      isIncoming: request.isIncoming,
                      requestedAt: DateTime.now().subtract(
                        Duration(hours: (request.id.hashCode.abs() % 12) + 1),
                      ),
                      onMessage: () => context.push('/chat/${profile.id}'),
                      onAccept: () async {
                        await ref.read(repositoryProvider).updateRequestStatus(request.id, RequestStatus.accepted);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('🎉 Accepted swap request from ${profile.name}!'),
                              action: SnackBarAction(
                                label: 'UNDO',
                                textColor: AppColors.softGold,
                                onPressed: () async {
                                  await ref.read(repositoryProvider).updateRequestStatus(request.id, RequestStatus.pending);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Reverted request back to Pending.')),
                                    );
                                  }
                                },
                              ),
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        }
                      },
                      onDecline: () async {
                        await ref.read(repositoryProvider).updateRequestStatus(request.id, RequestStatus.declined);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Declined swap request.')),
                          );
                        }
                      },
                      onUndoAccept: () async {
                        await ref.read(repositoryProvider).updateRequestStatus(request.id, RequestStatus.pending);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reverted request back to Pending.')),
                          );
                        }
                      },
                      onComplete: () => context.push('/complete/${request.id}'),
                      onRate: () => context.push('/rating/${request.id}'),
                    );
                  }),
              ],
            );
          },
        ),
  );
}

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(messagesProvider).value ?? const [];
    return PageFrame(
      title: 'Messages',
      child: (messages.isEmpty || ref.watch(debugForceEmptyStatesProvider))
          ? FriendlyEmptyState(
              imageAsset: 'assets/illustrations/empty/empty_messages.png',
              title: 'No messages yet',
              message: 'Start a conversation after you send or accept a swap request.',
              actionLabel: 'Explore nearby',
              onAction: () => context.go('/nearby'),
            )
          : Column(
              children: messages
                  .map((message) => message.profileId)
                  .toSet()
                  .map((profileId) {
                    final profile = ref
                        .read(repositoryProvider)
                        .profile(profileId);
                    final last = messages
                        .where((message) => message.profileId == profileId)
                        .last;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpace.sm),
                      child: AppCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          onTap: () => context.push('/chat/$profileId'),
                          leading: ProfileAvatar(
                            profile: profile,
                            compact: true,
                          ),
                          title: Text(profile.name),
                          subtitle: Text(
                            last.body,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: last.isPendingSync
                              ? const Icon(
                                  Icons.schedule,
                                  color: AppColors.warning,
                                )
                              : null,
                        ),
                      ),
                    );
                  })
                  .toList(),
            ),
    );
  }
}

class MyProfileScreen extends ConsumerStatefulWidget {
  const MyProfileScreen({super.key});

  @override
  ConsumerState<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends ConsumerState<MyProfileScreen> {
  bool _isCardExpanded = false;

  void _showCreditsHistory(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpace.lg,
            AppSpace.lg,
            AppSpace.lg,
            AppSpace.lg + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpace.md),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Center(
                child: Image.asset(
                  'assets/illustrations/empty/empty_credits.png',
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: AppSpace.sm),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.softGold,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.stars_rounded, color: AppColors.primary, size: 26),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  Text(
                    'Skill Credits Activity',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.xs),
              const Text('Earned by teaching, spent by learning from neighbours:'),
              const SizedBox(height: AppSpace.md),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(backgroundColor: AppColors.softTeal, child: Icon(Icons.arrow_upward, color: AppColors.success)),
                title: Text('Taught Graphic Design (+3 credits)'),
                subtitle: Text('Swap with Rohan • Yesterday'),
              ),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(backgroundColor: AppColors.softTeal, child: Icon(Icons.arrow_upward, color: AppColors.success)),
                title: Text('Taught Branding Basics (+2 credits)'),
                subtitle: Text('Swap with Neha • 3 days ago'),
              ),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(backgroundColor: AppColors.softCoral, child: Icon(Icons.arrow_downward, color: AppColors.accent)),
                title: Text('Learned Sourdough Baking (-2 credits)'),
                subtitle: Text('Swap with Maya • 1 week ago'),
              ),
              const SizedBox(height: AppSpace.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadii.input),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myProfileAsync = ref.watch(myProfileProvider);
    final profile = myProfileAsync.value ?? ref.read(repositoryProvider).myProfile;

    return PageFrame(
      title: profile.name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _isCardExpanded = !_isCardExpanded);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ProfileAvatar(profile: profile),
                        const SizedBox(width: AppSpace.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    profile.name,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  if (profile.isVerified) ...[
                                    const SizedBox(width: 4),
                                    const Icon(Icons.verified, color: AppColors.primary, size: 18),
                                  ],
                                ],
                              ),
                              Text('${profile.rating.toStringAsFixed(1)} ★  •  Response rate ${profile.responseRate}%'),
                              const SizedBox(height: 2),
                              const Text('12 swaps completed', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Icon(
                          _isCardExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    if (_isCardExpanded) ...[
                      const Divider(height: 24),
                      const Text(
                        'Bio & Intro',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.bio.isNotEmpty ? profile.bio : 'No bio added yet.',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: AppSpace.md),
                      const Text(
                        'Skills Offered / Teach',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: profile.offers
                            .map((s) => SkillChip(label: s, selected: true))
                            .toList(),
                      ),
                      const SizedBox(height: AppSpace.md),
                      const Text(
                        'Skills Wanted / Learn',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.accent),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: profile.wants
                            .map((s) => SkillChip(label: s))
                            .toList(),
                      ),
                      const SizedBox(height: AppSpace.md),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => context.push('/edit-profile'),
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: const Text('Edit Profile Details'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.primary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 4),
                      const Center(
                        child: Text(
                          'Tap card to expand details ▾',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          const _ProfileSnapshot(),
          const SizedBox(height: AppSpace.sm),
          SkillCreditsBalance(
            credits: 8,
            earnedThisMonth: 5,
            spentThisMonth: 2,
            onHistoryTap: () => _showCreditsHistory(context),
          ),
          const SizedBox(height: AppSpace.sm),
          const _NeighbourhoodBadges(),
          const SizedBox(height: AppSpace.sm),
          const _ProfileSkills(),
          const SizedBox(height: AppSpace.sm),
          const _RecentKindWordsCarousel(),
          const SizedBox(height: AppSpace.sm),
          _SettingsTile(
            icon: Theme.of(context).brightness == Brightness.dark
                ? Icons.dark_mode_rounded
                : Icons.light_mode_rounded,
            title: 'App Theme System',
            subtitle: ref.watch(appThemeModeProvider) == ThemeMode.dark
                ? 'Dark Theme Active (Warm Dark System v1)'
                : 'Light Theme Active',
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(appThemeModeProvider.notifier).toggleDark();
            },
          ),
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Edit profile & skills',
            subtitle: 'Bio, offered skills & GPS location',
            onTap: () => context.push('/edit-profile'),
          ),
          _SettingsTile(
            icon: Icons.campaign_outlined,
            title: 'Standing offers',
            onTap: () => context.push('/standing-offers'),
          ),
          _SettingsTile(
            icon: Icons.shield_outlined,
            title: 'Safety & verification',
            onTap: () => context.push('/safety'),
          ),
          _SettingsTile(
            icon: Icons.cloud_outlined,
            title: 'Offline data',
            onTap: () => context.push('/offline-data'),
          ),
          _SettingsTile(
            icon: Icons.tune_outlined,
            title: 'Availability',
            subtitle:
                ref.watch(preferencesProvider).value?.isAvailableEvenings == true
                ? 'Evenings'
                : 'Flexible',
            onTap: () {},
          ),
          const SizedBox(height: AppSpace.sm),
          const _DeveloperDebugSection(),
        ],
      ),
    );
  }
}

class _NeighbourhoodBadges extends StatelessWidget {
  const _NeighbourhoodBadges();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Neighbourhood Badges', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: AppSpace.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _BadgeItem(icon: '🥇', label: 'First Swap'),
              _BadgeItem(icon: '🌟', label: 'Super Teacher'),
              _BadgeItem(icon: '🛡️', label: 'Verified Local'),
            ],
          ),
        ],
      ),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  const _BadgeItem({required this.icon, required this.label});
  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF332B18) : AppColors.softGold,
            shape: BoxShape.circle,
          ),
          child: Text(icon, style: const TextStyle(fontSize: 22)),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? DarkColors.stone : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class PageFrame extends ConsumerWidget {
  const PageFrame({
    required this.title,
    required this.child,
    super.key,
    this.subtitle,
    this.subtitleWidget,
  });
  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection =
        ref.watch(connectionProvider).value ?? AppConnectionState.online;
    final pending = ref.watch(outboxProvider).value?.length ?? 0;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            OfflineBanner(connection: connection, pendingCount: pending),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.lg,
                AppSpace.lg,
                AppSpace.lg,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  if (subtitleWidget != null)
                    subtitleWidget!
                  else if (subtitle != null)
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpace.lg),
                child: child,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({required this.profile, super.key, this.compact = false});
  final SkillProfile profile;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final radius = compact ? 21.0 : 28.0;
    if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
      final url = profile.avatarUrl!;
      if (url.startsWith('http')) {
        return CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.softGold,
          backgroundImage: NetworkImage(url),
        );
      } else {
        try {
          final file = File(url);
          if (file.existsSync()) {
            return CircleAvatar(
              radius: radius,
              backgroundColor: AppColors.softGold,
              backgroundImage: FileImage(file),
            );
          }
        } catch (_) {}
      }
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.softGold,
      child: Text(
        profile.initials,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
          fontSize: compact ? 13 : 16,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? DarkColors.teal : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpace.xs),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: AppRadii.card,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.md,
              vertical: 14,
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? DarkColors.stone : AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: isDark ? DarkColors.stone : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeveloperDebugSection extends ConsumerWidget {
  const _DeveloperDebugSection();

  void _showEmptyStateGallery(BuildContext context) {
    HapticFeedback.lightImpact();
    final items = const [
      (
        'empty_nearby.png',
        'Nearby Main Feed',
        'Displayed when no neighbours are registered in the saved area.',
      ),
      (
        'empty_search.png',
        'Search Results',
        'Displayed when search term returns zero matching skills or people.',
      ),
      (
        'empty_radius.png',
        'Radius / Category Filter',
        'Displayed when distance radius or category filter yields no results.',
      ),
      (
        'empty_request_send.png',
        'Request Sent Confirmation',
        'Displayed on the Request Sent confirmation screen after submitting a swap request.',
      ),
      (
        'empty_requests .png',
        'Incoming & Outgoing Requests',
        'Displayed in Requests tab when no pending swap requests exist.',
      ),
      (
        'empty_history.png',
        'Completed Swaps History',
        'Displayed in Completed tab when no swaps have been completed yet.',
      ),
      (
        'empty_messages.png',
        'Messages & Chat',
        'Displayed in Messages tab when user has zero active conversations.',
      ),
      (
        'empty_credits.png',
        'Skill Credits Balance',
        'Displayed when user has 0 skill credits or views rewards activity.',
      ),
      (
        'empty_offline.png',
        'Offline Data Screen',
        'Displayed when app is offline or managing local storage sync.',
      ),
      (
        'empty_standing_offers.png',
        'Standing Offers',
        'Displayed when user has no active standing community offers.',
      ),
      (
        'empty_skills.png',
        'Profile Skills List',
        'Displayed during profile setup before user adds offered skills.',
      ),
      (
        'empty_ratings.png',
        'Reviews & Ratings',
        'Displayed when user or profile has no ratings / reviews yet.',
      ),
      (
        'empty_invite.png',
        'Community / Invite',
        'Displayed to encourage inviting local neighbours to the network.',
      ),
      (
        'empty_success_swap.png',
        'Swap Completion Celebration',
        'Displayed upon completing a successful swap session.',
      ),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: AppSpace.md),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppSpace.md),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.collections_outlined, color: AppColors.primary, size: 26),
                    const SizedBox(width: AppSpace.sm),
                    Expanded(
                      child: Text(
                        'Empty State Gallery (13 Assets)',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.xs),
                const Text(
                  'Matched directly with emptystates.csv specification:',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: AppSpace.md),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpace.md),
                    itemBuilder: (_, index) {
                      final (file, title, desc) = items[index];
                      return Container(
                        padding: const EdgeInsets.all(AppSpace.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppRadii.card,
                          border: Border.all(color: AppColors.border),
                          boxShadow: AppShadows.card,
                        ),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/illustrations/empty/$file',
                              height: 120,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 40, color: AppColors.accent),
                            ),
                            const SizedBox(height: AppSpace.xs),
                            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(
                              desc,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'assets/illustrations/empty/$file',
                              style: const TextStyle(fontSize: 10, fontFamily: 'IBM Plex Mono', color: AppColors.primary),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forceEmpty = ref.watch(debugForceEmptyStatesProvider);

    return Container(
      margin: const EdgeInsets.only(top: AppSpace.sm),
      decoration: BoxDecoration(
        color: AppColors.softGold.withValues(alpha: 0.6),
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.md, AppSpace.md, AppSpace.md, 0),
            child: Row(
              children: const [
                Icon(Icons.bug_report_outlined, color: AppColors.warning, size: 20),
                SizedBox(width: 8),
                Text(
                  'Developer / Debug Mode',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          SwitchListTile(
            value: forceEmpty,
            activeThumbColor: AppColors.primary,
            title: const Text('Force Empty States (Preview)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            subtitle: const Text(
              'Simulates cold start empty states across Nearby, Requests, and Messages',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            onChanged: (val) {
              HapticFeedback.lightImpact();
              ref.read(debugForceEmptyStatesProvider.notifier).set(val);
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.md, 0, AppSpace.md, AppSpace.md),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showEmptyStateGallery(context),
                    icon: const Icon(Icons.grid_view_rounded, size: 16),
                    label: const Text('View 13 Empty Illustrations Gallery'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      final service = ref.read(notificationServiceProvider);
                      await service.showSwapAcceptedNotification(
                        neighbourName: 'Rohan Verma',
                        skillOffered: 'Acoustic Guitar',
                        requestId: 'debug_test_123',
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🔔 Push alert triggered: "Rohan Verma accepted your swap!"'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.notifications_active, size: 16, color: Colors.white),
                    label: const Text('Test Push Notification Alert'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('⚡ Supabase Realtime WebSocket stream channel connected! Listening on public:swaps & public:messages.'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.bolt, size: 16),
                    label: const Text('Test Supabase Realtime Sync'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.accent),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSnapshot extends StatelessWidget {
  const _ProfileSnapshot();
  @override
  Widget build(BuildContext context) => const AppCard(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _Stat(value: '12', label: 'Swaps Done'),
        _Stat(value: '5', label: 'Skills Offered'),
        _Stat(value: '93%', label: 'Response Rate'),
      ],
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    ],
  );
}

class _ProfileSkills extends StatelessWidget {
  const _ProfileSkills();
  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('What you share', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: AppSpace.xs),
        Wrap(
          spacing: AppSpace.xs,
          runSpacing: AppSpace.xs,
          children: [
            SkillChip(label: 'Graphic Design', level: 'Expert'),
            SkillChip(label: 'Branding', level: 'Intermediate'),
            SkillChip(label: 'Canva', level: 'Beginner'),
          ],
        ),
        SizedBox(height: AppSpace.sm),
        Text('What you are learning', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: AppSpace.xs),
        Wrap(
          spacing: AppSpace.xs,
          runSpacing: AppSpace.xs,
          children: [
            SkillChip(label: 'Guitar', level: 'Beginner'),
            SkillChip(label: 'Gardening', level: 'Beginner'),
          ],
        ),
      ],
    ),
  );
}

class _RecentKindWordsCarousel extends StatefulWidget {
  const _RecentKindWordsCarousel();

  @override
  State<_RecentKindWordsCarousel> createState() => _RecentKindWordsCarouselState();
}

class _RecentKindWordsCarouselState extends State<_RecentKindWordsCarousel> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> testimonials = const [
    {
      'quote': '“Krish made the whole poster process feel easy and fun.”',
      'author': 'Kabir · Cycle repair swap',
    },
    {
      'quote': '“Super patient teacher! Loved working together on branding.”',
      'author': 'Rohan · Guitar swap',
    },
    {
      'quote': '“Punctual, helpful, and extremely friendly neighbour.”',
      'author': 'Neha · Yoga swap',
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(AppSpace.md, AppSpace.md, AppSpace.md, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 86,
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (idx) => setState(() => _currentPage = idx),
              itemCount: testimonials.length,
              itemBuilder: (context, index) {
                final item = testimonials[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.format_quote,
                      color: AppColors.accent,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpace.xs),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['quote']!,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item['author']!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: AppSpace.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              testimonials.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentPage == index ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentPage == index ? AppColors.accent : AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingCards extends StatelessWidget {
  const _LoadingCards();
  @override
  Widget build(BuildContext context) => Column(
    children: List.generate(
      3,
      (_) => Container(
        height: 142,
        margin: const EdgeInsets.only(bottom: AppSpace.sm),
        decoration: const BoxDecoration(
          color: AppColors.softTeal,
          borderRadius: AppRadii.card,
        ),
      ),
    ),
  );
}
