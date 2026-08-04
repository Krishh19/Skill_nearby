import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../domain/models.dart';

/// Small Drift-backed cache. SQL is intentionally isolated here so repositories
/// remain agnostic to the local database and can later use a generated schema.
class DriftLocalStore {
  DriftLocalStore._(this._database);

  final _RawCacheDatabase _database;

  static Future<DriftLocalStore> open() async {
    final directory = await getApplicationDocumentsDirectory();
    final databaseFile = File(path.join(directory.path, 'skill_nearby.sqlite'));
    final store = DriftLocalStore._(
      _RawCacheDatabase(NativeDatabase.createInBackground(databaseFile)),
    );
    await store._createSchema();
    return store;
  }

  /// Keeps repository tests fast without touching a device file system.
  static Future<DriftLocalStore> inMemory() async {
    final store = DriftLocalStore._(_RawCacheDatabase(NativeDatabase.memory()));
    await store._createSchema();
    return store;
  }

  Future<void> _createSchema() async {
    await _database.customStatement('''
      CREATE TABLE IF NOT EXISTS profiles (
        id TEXT PRIMARY KEY, payload TEXT NOT NULL, updated_at INTEGER NOT NULL
      )
    ''');
    await _database.customStatement('''
      CREATE TABLE IF NOT EXISTS skills (
        id TEXT PRIMARY KEY, profile_id TEXT NOT NULL, payload TEXT NOT NULL, updated_at INTEGER NOT NULL
      )
    ''');
    await _database.customStatement('''
      CREATE TABLE IF NOT EXISTS swap_requests (
        id TEXT PRIMARY KEY, payload TEXT NOT NULL, updated_at INTEGER NOT NULL
      )
    ''');
    await _database.customStatement('''
      CREATE TABLE IF NOT EXISTS messages (
        id TEXT PRIMARY KEY, request_id TEXT NOT NULL, payload TEXT NOT NULL, updated_at INTEGER NOT NULL
      )
    ''');
    await _database.customStatement('''
      CREATE TABLE IF NOT EXISTS ratings (
        id TEXT PRIMARY KEY, payload TEXT NOT NULL, updated_at INTEGER NOT NULL
      )
    ''');
    await _database.customStatement('''
      CREATE TABLE IF NOT EXISTS outbox (
        id TEXT PRIMARY KEY, kind TEXT NOT NULL, entity_id TEXT NOT NULL,
        created_at INTEGER NOT NULL, retry_count INTEGER NOT NULL DEFAULT 0, state TEXT NOT NULL
      )
    ''');
  }

  Future<void> cacheEntity({
    required String table,
    required String id,
    required String payload,
  }) => _database.customStatement(
    'INSERT OR REPLACE INTO $table (id, payload, updated_at) VALUES (?, ?, ?)',
    [id, payload, DateTime.now().millisecondsSinceEpoch],
  );

  Future<void> cacheMessage({
    required String id,
    required String requestId,
    required String payload,
  }) => _database.customStatement(
    'INSERT OR REPLACE INTO messages (id, request_id, payload, updated_at) VALUES (?, ?, ?, ?)',
    [id, requestId, payload, DateTime.now().millisecondsSinceEpoch],
  );

  Future<void> cacheOperation(
    PendingOperation operation,
  ) => _database.customStatement(
    'INSERT OR REPLACE INTO outbox (id, kind, entity_id, created_at, retry_count, state) VALUES (?, ?, ?, ?, ?, ?)',
    [
      operation.id,
      operation.kind.name,
      operation.entityId,
      operation.createdAt.millisecondsSinceEpoch,
      operation.retryCount,
      operation.state.name,
    ],
  );

  Future<void> removeOperation(String id) =>
      _database.customStatement('DELETE FROM outbox WHERE id = ?', [id]);
}

/// A small Drift database user for raw cache tables. It opens the executor
/// before custom SQL runs, while keeping database details out of repositories.
class _RawCacheDatabase extends GeneratedDatabase {
  _RawCacheDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  Iterable<TableInfo<Table, Object?>> get allTables => const [];

  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => const [];
}

/// Hive holds only small, user-owned preferences—not marketplace records.
class PreferencesStore {
  static const _boxName = 'skill_nearby_preferences';
  static const _onboardedKey = 'onboarded';
  static const _radiusKey = 'radiusKm';
  static const _eveningKey = 'availableEvenings';

  late final Box<dynamic> _box;

  PreferencesStore();

  PreferencesStore.forTesting(this._box);

  Future<void> open() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<dynamic>(_boxName);
  }

  AppPreferences read() => AppPreferences(
    onboardingComplete: _box.get(_onboardedKey, defaultValue: false) as bool,
    radiusKm: _box.get(_radiusKey, defaultValue: 2) as int,
    isAvailableEvenings: _box.get(_eveningKey, defaultValue: true) as bool,
  );

  Future<void> write(AppPreferences preferences) => _box.putAll({
    _onboardedKey: preferences.onboardingComplete,
    _radiusKey: preferences.radiusKm,
    _eveningKey: preferences.isAvailableEvenings,
  });
}
