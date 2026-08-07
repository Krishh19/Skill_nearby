import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    child: const _AppContent(),
  );
}

class _AppContent extends ConsumerWidget {
  const _AppContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(repositoryProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    SystemChrome.setSystemUIOverlayStyle(
      isDark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
              systemNavigationBarColor: DarkColors.bgRaised,
              systemNavigationBarIconBrightness: Brightness.light,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
              systemNavigationBarColor: AppColors.background,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
    );

    return MaterialApp.router(
      title: 'SkillNearby',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      darkTheme: appDarkTheme(),
      themeMode: themeMode,
      routerConfig: createRouter(repository),
    );
  }
}
