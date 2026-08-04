import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skill_nearby/design_system/components.dart';
import 'package:skill_nearby/domain/models.dart';

void main() {
  testWidgets('offline banner makes saved-data state explicit', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OfflineBanner(
            connection: AppConnectionState.offline,
            pendingCount: 2,
          ),
        ),
      ),
    );

    expect(find.textContaining('You’re offline'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
  });
}
