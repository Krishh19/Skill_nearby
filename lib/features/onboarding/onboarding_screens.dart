import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.lg),
        child: Column(
          children: [
            const SizedBox(height: AppSpace.md),
            const Icon(
              Icons.volunteer_activism,
              color: AppColors.accent,
              size: 52,
            ),
            const SizedBox(height: AppSpace.sm),
            Text(
              'Trade skills.\nBuild community.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: AppSpace.xs),
            Text(
              'Swap what you know for what you need — for free, locally.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpace.lg),
            Expanded(
              child: Image.asset(
                'assets/gettingstarted.png',
                fit: BoxFit.contain,
                semanticLabel: 'Neighbours sharing their skills',
              ),
            ),
            const SizedBox(height: AppSpace.md),
            AppButton(
              label: 'Get started',
              onPressed: () => context.go('/onboarding/location'),
            ),
          ],
        ),
      ),
    ),
  );
}

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  bool _requesting = false;
  String? _message;

  Future<void> _requestLocation() async {
    setState(() {
      _requesting = true;
      _message = null;
    });
    if (!await Geolocator.isLocationServiceEnabled()) {
      setState(() {
        _requesting = false;
        _message =
            'Location services are off. You can enable them later and still browse saved neighbours now.';
      });
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied)
      permission = await Geolocator.requestPermission();
    if (!mounted) return;
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _requesting = false;
        _message =
            'Location is disabled for SkillNearby. Open device settings to enable it later.';
      });
      return;
    }
    if (permission == LocationPermission.denied) {
      setState(() {
        _requesting = false;
        _message =
            'No problem — continue with saved nearby results and enable location later.';
      });
      return;
    }
    context.go('/onboarding/profile');
  }

  @override
  Widget build(BuildContext context) => OnboardingScaffold(
    title: 'Find people near you',
    subtitle:
        'Your approximate area helps show neighbours within a short walk or drive. Your precise location is never shown publicly.',
    illustration: const Icon(
      Icons.location_on_rounded,
      color: AppColors.accent,
      size: 110,
    ),
    details: [
      const _Benefit(
        icon: Icons.people_outline,
        label: 'See nearby skill swappers',
      ),
      const _Benefit(
        icon: Icons.shield_outlined,
        label: 'Safer, in-person meetings',
      ),
      const _Benefit(
        icon: Icons.lock_outline,
        label: 'No location is shared publicly',
      ),
      if (_message != null)
        Padding(
          padding: const EdgeInsets.only(top: AppSpace.sm),
          child: Text(_message!),
        ),
    ],
    primaryLabel: _requesting ? 'Checking location…' : 'Allow location',
    onPrimary: _requesting ? (_) {} : (_) => _requestLocation(),
    secondaryLabel: 'Not now',
    onSecondary: (context) => context.go('/onboarding/profile'),
  );
}

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});
  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _name = TextEditingController(text: 'Aanya Sharma');
  final _bio = TextEditingController(
    text: 'Graphic designer who loves teaching and photography 📸',
  );
  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => OnboardingScaffold(
    title: 'Let’s create your profile',
    subtitle:
        'A few friendly details help neighbours feel comfortable reaching out.',
    illustration: const CircleAvatar(
      radius: 48,
      backgroundColor: AppColors.softGold,
      child: Icon(Icons.person, color: AppColors.primary, size: 50),
    ),
    details: [
      TextField(
        controller: _name,
        decoration: const InputDecoration(labelText: 'Full name'),
      ),
      const SizedBox(height: AppSpace.sm),
      TextField(
        controller: _bio,
        minLines: 3,
        maxLines: 4,
        decoration: const InputDecoration(labelText: 'Short bio'),
      ),
    ],
    primaryLabel: 'Continue',
    onPrimary: (context) => context.go('/onboarding/skills'),
  );
}

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});
  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  final offered = <String>['Graphic Design', 'Canva Design', 'Photography'];
  final wanted = <String>['Guitar Lessons', 'Yoga', 'Cooking'];
  @override
  Widget build(BuildContext context) => OnboardingScaffold(
    title: 'Share what you know',
    subtitle: 'Choose a few skills to offer and a few you’d like to learn.',
    details: [
      Text(
        'What skills do you offer?',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: AppSpace.xs),
      Wrap(
        spacing: AppSpace.xs,
        runSpacing: AppSpace.xs,
        children: offered
            .map(
              (skill) => SkillChip(
                label: skill,
                selected: true,
                onDeleted: () => setState(() => offered.remove(skill)),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: AppSpace.lg),
      Text(
        'What skills do you want?',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: AppSpace.xs),
      Wrap(
        spacing: AppSpace.xs,
        runSpacing: AppSpace.xs,
        children: wanted
            .map(
              (skill) => SkillChip(
                label: skill,
                selected: true,
                onDeleted: () => setState(() => wanted.remove(skill)),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: AppSpace.lg),
      const AppCard(
        child: Row(
          children: [
            Icon(Icons.play_circle_outline, color: AppColors.primary),
            SizedBox(width: AppSpace.sm),
            Expanded(
              child: Text(
                'Add a short video (optional)\nLet neighbours see how you share your skills.',
              ),
            ),
          ],
        ),
      ),
    ],
    primaryLabel: 'Continue',
    onPrimary: (context) => context.go('/onboarding/preferences'),
  );
}

class PreferencesScreen extends ConsumerWidget {
  const PreferencesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferencesProvider).value;
    final radius = preferences?.radiusKm ?? 2;
    return OnboardingScaffold(
      title: 'Set your preferences',
      subtitle: 'You can always change these later in settings.',
      details: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Default search radius'),
              const SizedBox(height: AppSpace.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('0.5 km'),
                  Text(
                    '$radius km',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const Text('5 km'),
                ],
              ),
              Slider(
                value: radius.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                activeColor: AppColors.primary,
                onChanged: (value) =>
                    ref.read(repositoryProvider).setRadius(value.round()),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('When are you available?'),
              const SizedBox(height: AppSpace.xs),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Evenings'),
                value: preferences?.isAvailableEvenings ?? true,
                activeThumbColor: AppColors.primary,
                onChanged: (value) =>
                    ref.read(repositoryProvider).setAvailability(value),
              ),
            ],
          ),
        ),
      ],
      primaryLabel: 'Finish',
      onPrimary: (context) async {
        await ref.read(repositoryProvider).completeOnboarding();
        if (context.mounted) context.go('/nearby');
      },
    );
  }
}

class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    required this.title,
    required this.subtitle,
    required this.details,
    required this.primaryLabel,
    required this.onPrimary,
    super.key,
    this.illustration,
    this.secondaryLabel,
    this.onSecondary,
  });
  final String title;
  final String subtitle;
  final List<Widget> details;
  final String primaryLabel;
  final void Function(BuildContext) onPrimary;
  final Widget? illustration;
  final String? secondaryLabel;
  final void Function(BuildContext)? onSecondary;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IconButton(
              alignment: Alignment.centerLeft,
              icon: const Icon(Icons.arrow_back),
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/welcome'),
            ),
            if (illustration != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.md),
                  child: illustration,
                ),
              ),
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpace.xs),
            Text(subtitle),
            const SizedBox(height: AppSpace.lg),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: details,
                ),
              ),
            ),
            AppButton(label: primaryLabel, onPressed: () => onPrimary(context)),
            if (secondaryLabel != null)
              TextButton(
                onPressed: () => onSecondary?.call(context),
                child: Text(secondaryLabel!),
              ),
          ],
        ),
      ),
    ),
  );
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpace.md),
    child: Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: AppSpace.sm),
        Expanded(child: Text(label)),
      ],
    ),
  );
}
