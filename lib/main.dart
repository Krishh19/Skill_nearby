import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';

import 'app.dart';
import 'data/local_store.dart';
import 'data/notification_service.dart';
import 'data/repositories.dart';
import 'data/supabase_backend.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = PreferencesStore();
  await preferences.open();
  await initializeSupabase();

  final notificationService = NotificationService();
  await notificationService.initialize();

  final repository = SkillRepository(
    localStore: await DriftLocalStore.open(),
    preferencesStore: preferences,
    transport: configuredTransport(),
    notificationService: notificationService,
  );
  // The repository remains the only place that reacts to connection changes.
  unawaited(
    ConnectivityService(
      Connectivity(),
    ).watch().listen(repository.setConnection).asFuture<void>(),
  );
  runApp(SkillNearbyApp(repository: repository));
}
