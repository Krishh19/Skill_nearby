import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories.dart';
import '../domain/models.dart';

final repositoryProvider = Provider<SkillRepository>(
  (ref) => throw UnimplementedError('Override repositoryProvider at startup.'),
);
final profilesProvider = StreamProvider<List<SkillProfile>>(
  (ref) => ref.watch(repositoryProvider).watchProfiles(),
);
final requestsProvider = StreamProvider<List<SwapRequest>>(
  (ref) => ref.watch(repositoryProvider).watchRequests(),
);
final messagesProvider = StreamProvider<List<ChatMessage>>(
  (ref) => ref.watch(repositoryProvider).watchMessages(),
);
final outboxProvider = StreamProvider<List<PendingOperation>>(
  (ref) => ref.watch(repositoryProvider).watchOutbox(),
);
final connectionProvider = StreamProvider<AppConnectionState>(
  (ref) => ref.watch(repositoryProvider).watchConnection(),
);
final preferencesProvider = StreamProvider<AppPreferences>(
  (ref) => ref.watch(repositoryProvider).watchPreferences(),
);
final myProfileProvider = StreamProvider<SkillProfile>(
  (ref) => ref.watch(repositoryProvider).watchMyProfile(),
);

class DebugForceEmptyStatesNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void set(bool val) => state = val;
}

final debugForceEmptyStatesProvider =
    NotifierProvider<DebugForceEmptyStatesNotifier, bool>(
      DebugForceEmptyStatesNotifier.new,
    );

class AppThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;

  void setThemeMode(ThemeMode mode) => state = mode;
  void toggleDark() =>
      state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
}

final appThemeModeProvider = NotifierProvider<AppThemeModeNotifier, ThemeMode>(
  AppThemeModeNotifier.new,
);
