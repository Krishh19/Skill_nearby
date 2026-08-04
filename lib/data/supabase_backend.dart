import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/models.dart';
import 'repositories.dart';

/// Compile-time configuration. Never ship a service-role key in the app.
class SupabaseConfig {
  const SupabaseConfig({required this.url, required this.publishableKey});

  final String url;
  final String publishableKey;

  bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;

  static const fromEnvironment = SupabaseConfig(
    url: String.fromEnvironment('SUPABASE_URL'),
    publishableKey: String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
  );
}

Future<bool> initializeSupabase([
  SupabaseConfig config = SupabaseConfig.fromEnvironment,
]) async {
  if (!config.isConfigured) return false;
  await Supabase.initialize(
    url: config.url,
    publishableKey: config.publishableKey,
  );
  return true;
}

/// Applies queued local operations through one idempotent Postgres RPC.
/// The SQL function compares client_updated_at with the server row version and
/// returns `conflict` instead of silently overwriting a newer remote change.
class SupabaseRemoteTransport implements RemoteTransport {
  SupabaseRemoteTransport(this.client);

  final SupabaseClient client;

  @override
  Future<void> send(PendingOperation operation) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('Sign in required to sync changes.');
    }
    final result = await client.rpc<Map<String, dynamic>>(
      'apply_sync_operation',
      params: {
        'p_operation_id': operation.id,
        'p_actor_id': userId,
        'p_kind': operation.kind.name,
        'p_entity_id': operation.entityId,
        'p_payload': operation.payload,
        'p_client_created_at': operation.createdAt.toUtc().toIso8601String(),
      },
    );
    if (result['status'] == 'conflict') {
      throw SyncConflictException(
        operation.entityId,
        result['server_updated_at']?.toString(),
      );
    }
  }
}

class SyncConflictException implements Exception {
  const SyncConflictException(this.entityId, this.serverUpdatedAt);
  final String entityId;
  final String? serverUpdatedAt;
  @override
  String toString() => 'Remote change won for $entityId';
}

class SupabaseAuthService {
  SupabaseAuthService(this.client);
  final SupabaseClient client;

  Stream<AuthState> get changes => client.auth.onAuthStateChange;
  User? get currentUser => client.auth.currentUser;

  Future<AuthResponse> signIn(String email, String password) =>
      client.auth.signInWithPassword(email: email, password: password);

  Future<AuthResponse> signUp(String email, String password) =>
      client.auth.signUp(email: email, password: password);

  Future<void> signOut() => client.auth.signOut();

  /// Reads current user entitlement tier ('free', 'plus', 'pro')
  Future<String> fetchSubscriptionTier() async {
    final user = currentUser;
    if (user == null) return 'free';
    final response = await client
        .from('profiles')
        .select('subscription_tier, subscription_expires_at')
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) return 'free';
    final tier = response['subscription_tier']?.toString() ?? 'free';
    final expiresAtRaw = response['subscription_expires_at']?.toString();
    if (expiresAtRaw != null) {
      final expiresAt = DateTime.parse(expiresAtRaw);
      if (DateTime.now().isAfter(expiresAt)) return 'free';
    }
    return tier;
  }
}

class SupabaseMediaService {
  SupabaseMediaService(this.client, {this.bucket = 'profile-media'});
  final SupabaseClient client;
  final String bucket;

  Future<String> uploadProfileMedia({
    required String userId,
    required File file,
  }) async {
    final objectPath =
        '$userId/${DateTime.now().microsecondsSinceEpoch}-${file.uri.pathSegments.last}';
    await client.storage
        .from(bucket)
        .upload(
          objectPath,
          file,
          fileOptions: const FileOptions(upsert: false),
        );
    return client.storage.from(bucket).getPublicUrl(objectPath);
  }
}

class SupabaseRealtimeService {
  SupabaseRealtimeService(this.client);
  final SupabaseClient client;

  RealtimeChannel subscribeToUser(
    String userId,
    void Function(PostgresChangePayload) onChange,
  ) {
    return client
        .channel('user-$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'swaps',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'requester_id',
            value: userId,
          ),
          callback: onChange,
        )
        .subscribe();
  }
}

class NearbyProfileGateway {
  NearbyProfileGateway(this.client);
  final SupabaseClient client;

  Future<List<Map<String, dynamic>>> nearby({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    final result = await client.rpc<List<dynamic>>(
      'nearby_profiles',
      params: {
        'p_latitude': latitude,
        'p_longitude': longitude,
        'p_radius_km': radiusKm,
      },
    );
    return result.cast<Map<String, dynamic>>();
  }
}

RemoteTransport configuredTransport() {
  if (!SupabaseConfig.fromEnvironment.isConfigured) {
    return MockRemoteTransport();
  }
  return SupabaseRemoteTransport(Supabase.instance.client);
}
