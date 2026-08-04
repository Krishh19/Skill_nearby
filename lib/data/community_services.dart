import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Stores map-pack metadata locally. A platform map renderer can later attach
/// downloaded tiles to [filePath] without changing the repository contract.
class OfflineMapPackStore {
  OfflineMapPackStore(this._box);
  final Box<dynamic> _box;

  Future<void> save({
    required String regionId,
    required String filePath,
    required DateTime downloadedAt,
  }) => _box.put(
    regionId,
    jsonEncode({
      'filePath': filePath,
      'downloadedAt': downloadedAt.toIso8601String(),
    }),
  );

  Map<String, dynamic>? read(String regionId) {
    final raw = _box.get(regionId);
    if (raw is! String) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}

class CommunitySafetyService {
  CommunitySafetyService(this.client);
  final SupabaseClient client;

  Future<void> submitReport({
    required String subjectId,
    required String reason,
    required String details,
  }) async {
    await client.from('reports').insert({
      'reporter_id': client.auth.currentUser!.id,
      'subject_id': subjectId,
      'reason': reason,
      'details': details,
    });
  }

  Future<void> submitVerification({
    required String profileId,
    required String method,
  }) async {
    await client.from('verification_requests').insert({
      'profile_id': profileId,
      'method': method,
    });
  }
}
