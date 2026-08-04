import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:skill_nearby/data/local_store.dart';
import 'package:skill_nearby/data/repositories.dart';
import 'package:skill_nearby/domain/models.dart';

class RecordingTransport implements RemoteTransport {
  final sent = <PendingOperation>[];
  @override
  Future<void> send(PendingOperation operation) async => sent.add(operation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'offline request is optimistic, queued, and syncs FIFO on reconnect',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'skill_nearby_test',
      );
      Hive.init(directory.path);
      final preferences = PreferencesStore.forTesting(
        await Hive.openBox<dynamic>('preferences_test'),
      );
      final transport = RecordingTransport();
      final repository = SkillRepository(
        localStore: await DriftLocalStore.inMemory(),
        preferencesStore: preferences,
        transport: transport,
      );

      await repository.setConnection(AppConnectionState.offline);
      await repository.createSwapRequest(
        profileId: 'rohan',
        wantedSkill: 'Guitar Lessons',
        offeredSkill: 'Graphic Design',
        message: 'Happy to help!',
        preferredTime: 'Evenings',
      );

      expect(repository.currentRequests.last.isPendingSync, isTrue);
      expect(repository.pendingOperations, hasLength(1));
      expect(transport.sent, isEmpty);

      await repository.setConnection(AppConnectionState.online);

      expect(transport.sent.single.kind, OperationKind.requestSwap);
      expect(repository.pendingOperations, isEmpty);
      expect(repository.currentRequests.last.isPendingSync, isFalse);
    },
  );

  test('local profile snapshots replay to late subscribers', () async {
    final directory = await Directory.systemTemp.createTemp(
      'skill_nearby_replay_test',
    );
    Hive.init(directory.path);
    final repository = SkillRepository(
      localStore: await DriftLocalStore.inMemory(),
      preferencesStore: PreferencesStore.forTesting(
        await Hive.openBox<dynamic>('preferences_replay_test'),
      ),
      transport: RecordingTransport(),
    );

    final profiles = await repository.watchProfiles().first;

    expect(profiles, isNotEmpty);
    expect(profiles.first.name, 'Rohan Verma');
  });
}
