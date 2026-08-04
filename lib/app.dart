import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/providers.dart';
import 'app/router.dart';
import 'data/repositories.dart';
import 'design_system/app_theme.dart';

class SkillNearbyApp extends StatelessWidget {
  const SkillNearbyApp({required this.repository, super.key});
  final SkillRepository repository;

  @override
  Widget build(BuildContext context) => ProviderScope(
    overrides: [repositoryProvider.overrideWithValue(repository)],
    child: MaterialApp.router(
      title: 'SkillNearby',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      routerConfig: createRouter(repository),
    ),
  );
}
