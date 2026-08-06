import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/chat_quick_actions.dart';
import '../../design_system/components.dart';
import '../../design_system/swap_proposal_widget.dart';
import '../../domain/models.dart';
import '../home/home_screen.dart';

class ProfileDetailScreen extends ConsumerWidget {
  const ProfileDetailScreen({required this.profileId, super.key});
  final String profileId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.read(repositoryProvider).profile(profileId);
    return DetailScaffold(
      title: 'Profile',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            child: Column(
              children: [
                ProfileAvatar(profile: profile),
                const SizedBox(height: AppSpace.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      profile.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    if (profile.isVerified)
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(Icons.verified, color: AppColors.primary),
                      ),
                  ],
                ),
                Text(
                  '${profile.distanceKm.toStringAsFixed(1)} km away  •  ★ ${profile.rating.toStringAsFixed(1)} (${profile.responseRate}% response rate)',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.md),
          _Section(
            title: 'Skills I offer',
            child: Wrap(
              spacing: AppSpace.xs,
              runSpacing: AppSpace.xs,
              children: profile.offers
                  .map((skill) => SkillChip(label: skill, selected: true))
                  .toList(),
            ),
          ),
          _Section(
            title: 'Skills I want',
            child: Wrap(
              spacing: AppSpace.xs,
              runSpacing: AppSpace.xs,
              children: profile.wants
                  .map((skill) => SkillChip(label: skill))
                  .toList(),
            ),
          ),
          if (profile.hasVideo)
            _Section(
              title: 'Intro video',
              child: const AppCard(
                child: Row(
                  children: [
                    Icon(
                      Icons.play_circle_fill,
                      color: AppColors.accent,
                      size: 38,
                    ),
                    SizedBox(width: AppSpace.sm),
                    Expanded(child: Text('A 20-second hello from Rohan')),
                  ],
                ),
              ),
            ),
          _Section(title: 'About me', child: Text(profile.bio)),
          const AppCard(
            child: Row(
              children: [
                Icon(Icons.shield_outlined, color: AppColors.primary),
                SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Text(
                    'Keep plans in chat, choose a public meeting place, and trust your instincts.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          AppButton(
            label: 'Request swap',
            onPressed: () => context.push('/request/$profileId'),
          ),
        ],
      ),
    );
  }
}

class RequestSwapScreen extends StatefulWidget {
  const RequestSwapScreen({required this.profileId, super.key});
  final String profileId;
  @override
  State<RequestSwapScreen> createState() => _RequestSwapScreenState();
}

class _RequestSwapScreenState extends State<RequestSwapScreen> {
  String wanted = 'Guitar Lessons';
  String offered = 'Graphic Design';
  String preferredTime = 'Weekday evenings';
  final message = TextEditingController(
    text:
        'Hi! I’d love to learn guitar from you. I can help you with graphic design in return.',
  );

  @override
  void dispose() {
    message.dispose();
    super.dispose();
  }

  void _selectPreferredTime(BuildContext context) {
    HapticFeedback.lightImpact();
    final times = [
      'Weekday evenings',
      'Weekend mornings',
      'Weekend afternoons',
      'Flexible / Any time',
    ];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select preferred time', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpace.sm),
              ...times.map((t) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      preferredTime == t ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: AppColors.primary,
                    ),
                    title: Text(t, style: const TextStyle(fontWeight: FontWeight.w500)),
                    onTap: () {
                      setState(() => preferredTime = t);
                      Navigator.pop(ctx);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Consumer(
    builder: (context, ref, _) {
      final profile = ref.read(repositoryProvider).profile(widget.profileId);
      return DetailScaffold(
        title: 'Request a swap',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'You want from ${profile.name}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpace.xs),
            Wrap(
              spacing: AppSpace.xs,
              children: profile.offers
                  .map(
                    (skill) => ChoiceChip(
                      label: Text(skill),
                      selected: wanted == skill,
                      selectedColor: AppColors.softTeal,
                      onSelected: (_) => setState(() => wanted = skill),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpace.lg),
            Text('You offer', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpace.xs),
            Wrap(
              spacing: AppSpace.xs,
              children: ['Graphic Design', 'Canva Design', 'Photography']
                  .map(
                    (skill) => ChoiceChip(
                      label: Text(skill),
                      selected: offered == skill,
                      selectedColor: AppColors.softTeal,
                      onSelected: (_) => setState(() => offered = skill),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpace.lg),
            TextField(
              controller: message,
              minLines: 3,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Message (optional)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSpace.md),
            InkWell(
              onTap: () => _selectPreferredTime(context),
              borderRadius: AppRadii.input,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadii.input,
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Preferred time',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            preferredTime,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpace.lg),
            AppButton(
              label: 'Review request',
              onPressed: () =>
                  context.push('/request-review/${widget.profileId}'),
            ),
          ],
        ),
      );
    },
  );
}

class RequestReviewScreen extends ConsumerStatefulWidget {
  const RequestReviewScreen({required this.profileId, super.key});
  final String profileId;

  @override
  ConsumerState<RequestReviewScreen> createState() => _RequestReviewScreenState();
}

class _RequestReviewScreenState extends ConsumerState<RequestReviewScreen> {
  bool _agreedToTerms = false;

  @override
  Widget build(BuildContext context) {
    final profile = ref.read(repositoryProvider).profile(widget.profileId);
    return DetailScaffold(
      title: 'Looks good!',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            child: Column(
              children: [
                ListTile(
                  leading: ProfileAvatar(profile: profile, compact: true),
                  title: const Text('You want'),
                  subtitle: const Text('Guitar Lessons'),
                ),
                const Divider(),
                const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.softGold,
                    child: Icon(Icons.person, color: AppColors.primary),
                  ),
                  title: Text('You offer'),
                  subtitle: Text('Graphic Design'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.md),
          const _Section(
            title: 'Safety tips for a great swap',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• Meet in public places'),
                Text('• Share live location only when comfortable'),
                Text('• Be respectful and communicate clearly'),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _agreedToTerms = !_agreedToTerms);
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      HapticFeedback.lightImpact();
                      setState(() => _agreedToTerms = val ?? false);
                    },
                  ),
                  const SizedBox(width: AppSpace.xs),
                  Expanded(
                    child: Text(
                      'I agree to the community guidelines',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _agreedToTerms ? AppColors.textPrimary : AppColors.textSecondary,
                        fontWeight: _agreedToTerms ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          AppButton(
            label: 'Send request',
            onPressed: () async {
              if (!_agreedToTerms) {
                HapticFeedback.heavyImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('⚠️ Please agree to the community guidelines before sending.'),
                    backgroundColor: AppColors.accent,
                  ),
                );
                return;
              }
              await ref
                  .read(repositoryProvider)
                  .createSwapRequest(
                    profileId: widget.profileId,
                    wantedSkill: 'Guitar Lessons',
                    offeredSkill: 'Graphic Design',
                    message: 'I’d love to learn guitar from you.',
                    preferredTime: 'Weekday evenings',
                  );
              if (context.mounted) context.go('/request-sent');
            },
          ),
        ],
      ),
    );
  }
}

class RequestSentScreen extends StatelessWidget {
  const RequestSentScreen({super.key});
  @override
  Widget build(BuildContext context) => DetailScaffold(
    title: '',
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.softTeal,
            child: Icon(
              Icons.volunteer_activism,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          Text(
            'Request sent!',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: AppSpace.xs),
          const Text(
            'Rohan will review your request. We’ll let you know when they respond.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpace.lg),
          AppButton(
            label: 'Go to requests',
            onPressed: () => context.go('/requests'),
          ),
          TextButton(
            onPressed: () => context.go('/nearby'),
            child: const Text('Back to nearby'),
          ),
        ],
      ),
    ),
  );
}

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({required this.profileId, super.key});
  final String profileId;
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final input = TextEditingController();

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  void _showSafetySheet(BuildContext context, String profileName) {
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
                const Icon(Icons.shield_outlined, color: AppColors.primary, size: 26),
                const SizedBox(width: AppSpace.sm),
                Text(
                  'Safety & Protection',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: AppSpace.xs),
            Text('Quick safety actions for your chat with $profileName:'),
            const SizedBox(height: AppSpace.sm),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.lightbulb_outline, color: AppColors.primary),
              title: const Text('Safety Guidelines'),
              subtitle: const Text('Always meet in public places for first swaps'),
              onTap: () {
                Navigator.pop(context);
                context.push('/safety');
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.flag_outlined, color: AppColors.accent),
              title: const Text('Report Concern'),
              subtitle: const Text('Notify moderators about inappropriate behavior'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report submitted to community team.')),
                );
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.block_outlined, color: AppColors.accent),
              title: const Text('Block User'),
              subtitle: const Text('Prevent further messages and request attempts'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$profileName has been blocked.')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.read(repositoryProvider).profile(widget.profileId);
    final messages =
        ref
            .watch(messagesProvider)
            .value
            ?.where((message) => message.profileId == widget.profileId)
            .toList() ??
        const [];
    final offline =
        ref.watch(connectionProvider).value == AppConnectionState.offline;

    return Scaffold(
      appBar: AppBar(
        title: Text(profile.name),
        actions: [
          IconButton(
            onPressed: () => _showSafetySheet(context, profile.name),
            icon: const Icon(Icons.shield_outlined),
            tooltip: 'Safety actions',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (offline)
              const OfflineBanner(
                connection: AppConnectionState.offline,
                pendingCount: 0,
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpace.md),
                itemCount: messages.length,
                itemBuilder: (_, index) {
                  final message = messages[index];
                  if (message.isProposal) {
                    return SwapProposalCard(
                      message: message,
                      onAccept: () async {
                        await ref
                            .read(repositoryProvider)
                            .updateProposalStatus(message.id, 'accepted');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('🎉 Swap Proposal Accepted! Session confirmed.')),
                          );
                        }
                      },
                      onDecline: () async {
                        await ref
                            .read(repositoryProvider)
                            .updateProposalStatus(message.id, 'declined');
                      },
                    );
                  }

                  return Align(
                    alignment: message.sentByMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: AppSpace.xs),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      constraints: const BoxConstraints(maxWidth: 290),
                      decoration: BoxDecoration(
                        color: message.sentByMe
                            ? AppColors.primary
                            : AppColors.surface,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: message.sentByMe ? const Radius.circular(16) : const Radius.circular(4),
                          bottomRight: message.sentByMe ? const Radius.circular(4) : const Radius.circular(16),
                        ),
                        boxShadow: message.sentByMe ? null : AppShadows.card,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.body,
                            style: TextStyle(
                              color: message.sentByMe
                                  ? AppColors.surface
                                  : AppColors.textPrimary,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                message.timeLabel,
                                style: TextStyle(
                                  color: message.sentByMe
                                      ? AppColors.surface.withOpacity(0.75)
                                      : AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                              if (message.sentByMe) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  message.isPendingSync
                                      ? Icons.schedule
                                      : Icons.done_all,
                                  size: 14,
                                  color: message.isPendingSync
                                      ? AppColors.softGold
                                      : AppColors.surface.withOpacity(0.85),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Quick Actions bar with comfortable breathing room
            Padding(
              padding: const EdgeInsets.only(top: AppSpace.xs),
              child: ChatQuickActions(
                onProposeMeeting: () {
                  final profile = ref.read(repositoryProvider).profile(widget.profileId);
                  SwapProposalSheet.show(
                    context,
                    profileName: profile.name,
                    offeredSkills: profile.offers,
                    wantedSkills: profile.wants,
                    onSendProposal: ({
                      required date,
                      required location,
                      required offeredSkill,
                      required wantedSkill,
                      required note,
                    }) async {
                      final body = note.isNotEmpty
                          ? note
                          : "Hey ${profile.name}! Proposing a swap session ($offeredSkill ↔ $wantedSkill) at $location.";
                      await ref.read(repositoryProvider).sendMessage(
                        profileId: widget.profileId,
                        body: body,
                        proposalDate: date,
                        proposalLocation: location,
                        offeredSkill: offeredSkill,
                        wantedSkill: wantedSkill,
                      );
                    },
                  );
                },
                onShareLocation: () => setState(
                  () => input.text = "Let's meet at Central Park entrance nearby!",
                ),
                onConfirmSwap: () => setState(
                  () => input.text = 'All set! Excited for our skill swap session.',
                ),
              ),
            ),
            const SizedBox(height: AppSpace.xs),

            Container(
              padding: const EdgeInsets.fromLTRB(AppSpace.sm, 4, AppSpace.sm, AppSpace.sm),
              color: AppColors.surface,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: input,
                      decoration: const InputDecoration(
                        hintText: 'Type a message…',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      if (input.text.trim().isEmpty) return;
                      final body = input.text.trim();
                      input.clear();
                      await ref
                          .read(repositoryProvider)
                          .sendMessage(profileId: widget.profileId, body: body);
                    },
                    icon: const Icon(Icons.send, color: AppColors.primary),
                    tooltip: 'Send message',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompleteSwapScreen extends ConsumerWidget {
  const CompleteSwapScreen({required this.requestId, super.key});
  final String requestId;
  @override
  Widget build(BuildContext context, WidgetRef ref) => DetailScaffold(
    title: 'Mark swap complete',
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 62,
            backgroundColor: AppColors.softGold,
            child: Icon(
              Icons.handshake_outlined,
              color: AppColors.accent,
              size: 70,
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          Text('Great job!', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: AppSpace.xs),
          const Text(
            'You and your neighbour completed a swap. Celebrate the small wins!',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpace.lg),
          AppButton(
            label: 'Confirm completion',
            onPressed: () async {
              await ref.read(repositoryProvider).completeSwap(requestId);
              if (context.mounted) context.go('/rating/$requestId');
            },
          ),
        ],
      ),
    ),
  );
}

class RatingScreen extends ConsumerStatefulWidget {
  const RatingScreen({required this.requestId, super.key});
  final String requestId;
  @override
  ConsumerState<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends ConsumerState<RatingScreen> {
  int stars = 5;
  final note = TextEditingController();
  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DetailScaffold(
    title: 'Rate your experience',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CircleAvatar(
          radius: 48,
          backgroundColor: AppColors.softTeal,
          child: Icon(
            Icons.workspace_premium,
            color: AppColors.primary,
            size: 54,
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        Text(
          'How did your swap go?',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpace.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (index) => IconButton(
              onPressed: () => setState(() => stars = index + 1),
              icon: Icon(
                index < stars ? Icons.star : Icons.star_border,
                color: AppColors.warning,
                size: 34,
              ),
            ),
          ),
        ),
        TextField(
          controller: note,
          minLines: 4,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Add a note (optional)',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        AppButton(
          label: 'Submit rating',
          onPressed: () async {
            await ref.read(repositoryProvider).submitRating(widget.requestId);
            if (context.mounted) context.go('/me');
          },
        ),
      ],
    ),
  );
}

class StandingOffersScreen extends StatelessWidget {
  const StandingOffersScreen({super.key});
  @override
  Widget build(BuildContext context) => DetailScaffold(
    title: 'Standing offers',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.palette_outlined, color: AppColors.primary),
            title: Text('Graphic design help'),
            subtitle: Text('Available on weekday evenings'),
            trailing: Switch(value: true, onChanged: null),
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        const FriendlyEmptyState(
          title: 'Offer a skill anytime',
          message:
              'Standing offers help friendly neighbours find you when the time is right.',
          actionLabel: 'Add an offer',
          onAction: _noAction,
        ),
      ],
    ),
  );
}

class SafetyScreen extends StatelessWidget {
  const SafetyScreen({super.key});
  @override
  Widget build(BuildContext context) => DetailScaffold(
    title: 'Safety & verification',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.verified_user_outlined,
              color: AppColors.primary,
            ),
            title: Text('Identity verification'),
            subtitle: Text('Optional — builds trust with neighbours'),
            trailing: Icon(Icons.chevron_right),
          ),
        ),
        const SizedBox(height: AppSpace.md),
        const _Section(
          title: 'Meet thoughtfully',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• Choose public places for first swaps'),
              Text('• Keep conversations in SkillNearby'),
              Text('• Share live location only with someone you trust'),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.md),
        AppButton(
          label: 'Report a concern',
          isSecondary: true,
          icon: Icons.flag_outlined,
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Thanks. This prototype would open a reporting flow.',
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class OfflineDataScreen extends ConsumerWidget {
  const OfflineDataScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection =
        ref.watch(connectionProvider).value ?? AppConnectionState.online;
    final isOffline = connection == AppConnectionState.offline;
    return DetailScaffold(
      title: 'Offline data',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                isOffline ? Icons.cloud_off : Icons.cloud_done,
                color: isOffline ? AppColors.accent : AppColors.success,
              ),
              title: Text(isOffline ? 'Offline mode is on' : 'You’re online'),
              subtitle: Text(
                isOffline
                    ? 'Browsing saved neighbourhood data.'
                    : 'Queued actions sync automatically.',
              ),
            ),
          ),
          const SizedBox(height: AppSpace.md),
          const AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.storage_outlined, color: AppColors.primary),
              title: Text('Saved neighbourhood data'),
              subtitle: Text(
                'Profiles, chats, swaps, and queued actions are kept on this device.',
              ),
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          AppButton(
            label: isOffline ? 'Go online and sync' : 'Simulate offline mode',
            isSecondary: true,
            onPressed: () => ref
                .read(repositoryProvider)
                .setConnection(
                  isOffline
                      ? AppConnectionState.online
                      : AppConnectionState.offline,
                ),
          ),
        ],
      ),
    );
  }
}

class DetailScaffold extends StatelessWidget {
  const DetailScaffold({required this.title, required this.child, super.key});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Scaffold(
          appBar: AppBar(title: Text(title), backgroundColor: AppColors.background),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpace.lg),
              child: child,
            ),
          ),
        ),
      );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpace.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpace.xs),
        child,
      ],
    ),
  );
}

void _noAction() {}
