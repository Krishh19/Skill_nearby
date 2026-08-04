import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:skill_nearby/main.dart' as app;

/// Device-level acceptance flow. Run with `flutter test integration_test` on a
/// configured emulator/device; it intentionally does not require a Supabase
/// project when validating the local-first path.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('onboarding to offline-first shell', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Welcome to SkillNearby'), findsOneWidget);
  });
}
