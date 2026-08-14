import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/models.dart';
import 'app_theme.dart';

class SwapProposalSheet extends StatefulWidget {
  const SwapProposalSheet({
    required this.profileName,
    required this.offeredSkills,
    required this.wantedSkills,
    required this.onSendProposal,
    super.key,
  });

  final String profileName;
  final List<String> offeredSkills;
  final List<String> wantedSkills;
  final void Function({
    required DateTime date,
    required String location,
    required String offeredSkill,
    required String wantedSkill,
    required String note,
  })
  onSendProposal;

  static void show(
    BuildContext context, {
    required String profileName,
    required List<String> offeredSkills,
    required List<String> wantedSkills,
    required void Function({
      required DateTime date,
      required String location,
      required String offeredSkill,
      required String wantedSkill,
      required String note,
    })
    onSendProposal,
  }) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SwapProposalSheet(
          profileName: profileName,
          offeredSkills: offeredSkills,
          wantedSkills: wantedSkills,
          onSendProposal: onSendProposal,
        ),
      ),
    );
  }

  @override
  State<SwapProposalSheet> createState() => _SwapProposalSheetState();
}

class _SwapProposalSheetState extends State<SwapProposalSheet> {
  late DateTime _selectedDate;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 16, minute: 0);
  final TextEditingController _locationController = TextEditingController(
    text: 'Community Library, Table 4',
  );
  final TextEditingController _noteController = TextEditingController();

  late String _selectedOffered;
  late String _selectedWanted;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 2));
    _selectedOffered = widget.offeredSkills.isNotEmpty
        ? widget.offeredSkills.first
        : 'Skill Exchange';
    _selectedWanted = widget.wantedSkills.isNotEmpty
        ? widget.wantedSkills.first
        : 'Learning';
  }

  @override
  void dispose() {
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduledDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpace.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpace.md),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.softTeal,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.handshake_outlined,
                    color: AppColors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Propose Swap Session',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: AppColors.primary, fontSize: 20),
                      ),
                      Text(
                        'Propose a time & place to meet ${widget.profileName}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.md),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    borderRadius: AppRadii.input,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpace.sm),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: AppRadii.input,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: InkWell(
                    onTap: _pickTime,
                    borderRadius: AppRadii.input,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpace.sm),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: AppRadii.input,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedTime.format(context),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.sm),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.place_outlined,
                  color: AppColors.primary,
                ),
                labelText: 'Meeting Location',
                hintText: 'e.g. Local Cafe, Park, or Zoom link',
              ),
            ),
            const SizedBox(height: AppSpace.sm),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.notes, color: AppColors.primary),
                labelText: 'Session Note (Optional)',
                hintText: 'e.g. Bring your guitar & notebook!',
              ),
            ),
            const SizedBox(height: AppSpace.lg),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                widget.onSendProposal(
                  date: scheduledDateTime,
                  location: _locationController.text.trim(),
                  offeredSkill: _selectedOffered,
                  wantedSkill: _selectedWanted,
                  note: _noteController.text.trim(),
                );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.send_rounded),
              label: const Text('Send Swap Proposal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadii.input,
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SwapProposalCard extends StatelessWidget {
  const SwapProposalCard({
    required this.message,
    required this.onAccept,
    required this.onDecline,
    super.key,
  });

  final ChatMessage message;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final status = message.proposalStatus ?? 'pending';
    final isAccepted = status == 'accepted';
    final isDeclined = status == 'declined';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(
        color: isAccepted
            ? AppColors.softTeal
            : isDeclined
            ? AppColors.softCoral
            : AppColors.surface,
        borderRadius: AppRadii.card,
        border: Border.all(
          color: isAccepted
              ? AppColors.primary
              : isDeclined
              ? AppColors.accent
              : AppColors.border,
          width: 1.5,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(
                    Icons.handshake_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Swap Session Proposal',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isAccepted
                      ? AppColors.primary
                      : isDeclined
                      ? AppColors.accent
                      : AppColors.warning,
                  borderRadius: AppRadii.pill,
                ),
                child: Text(
                  status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            message.body,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpace.sm),
          Row(
            children: [
              const Icon(Icons.place, size: 16, color: AppColors.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  message.proposalLocation ?? 'Location agreed in chat',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (message.proposalDate != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.event, size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  '${message.proposalDate!.day}/${message.proposalDate!.month}/${message.proposalDate!.year} at ${message.proposalDate!.hour}:${message.proposalDate!.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          if (status == 'pending' && !message.sentByMe) ...[
            const SizedBox(height: AppSpace.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.accent),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Accept Swap'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
