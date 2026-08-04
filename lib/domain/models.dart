/// Domain types deliberately contain no Flutter, database, or transport code.
/// This keeps a future Supabase adapter independent from the presentation layer.

enum RequestStatus { pending, accepted, completed, declined }

enum OperationKind { requestSwap, sendMessage, completeSwap, submitRating }

enum OperationState { pending, syncing, failed }

enum AppConnectionState { online, offline }

class SkillProfile {
  const SkillProfile({
    required this.id,
    required this.name,
    required this.initials,
    required this.distanceKm,
    required this.rating,
    required this.responseRate,
    required this.offers,
    required this.wants,
    required this.bio,
    this.isVerified = false,
    this.hasVideo = false,
  });

  final String id;
  final String name;
  final String initials;
  final double distanceKm;
  final double rating;
  final int responseRate;
  final List<String> offers;
  final List<String> wants;
  final String bio;
  final bool isVerified;
  final bool hasVideo;
}

class SwapRequest {
  const SwapRequest({
    required this.id,
    required this.profileId,
    required this.wantedSkill,
    required this.offeredSkill,
    required this.message,
    required this.preferredTime,
    required this.status,
    required this.isIncoming,
    required this.isPendingSync,
  });

  final String id;
  final String profileId;
  final String wantedSkill;
  final String offeredSkill;
  final String message;
  final String preferredTime;
  final RequestStatus status;
  final bool isIncoming;
  final bool isPendingSync;

  SwapRequest copyWith({RequestStatus? status, bool? isPendingSync}) =>
      SwapRequest(
        id: id,
        profileId: profileId,
        wantedSkill: wantedSkill,
        offeredSkill: offeredSkill,
        message: message,
        preferredTime: preferredTime,
        status: status ?? this.status,
        isIncoming: isIncoming,
        isPendingSync: isPendingSync ?? this.isPendingSync,
      );
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.profileId,
    required this.body,
    required this.sentByMe,
    required this.timeLabel,
    required this.isPendingSync,
  });

  final String id;
  final String profileId;
  final String body;
  final bool sentByMe;
  final String timeLabel;
  final bool isPendingSync;

  ChatMessage copyWith({bool? isPendingSync}) => ChatMessage(
    id: id,
    profileId: profileId,
    body: body,
    sentByMe: sentByMe,
    timeLabel: timeLabel,
    isPendingSync: isPendingSync ?? this.isPendingSync,
  );
}

class PendingOperation {
  const PendingOperation({
    required this.id,
    required this.kind,
    required this.entityId,
    required this.createdAt,
    this.state = OperationState.pending,
    this.retryCount = 0,
    this.payload = const <String, Object?>{},
  });

  final String id;
  final OperationKind kind;
  final String entityId;
  final DateTime createdAt;
  final OperationState state;
  final int retryCount;

  /// Immutable operation data used by remote adapters for idempotent replay.
  final Map<String, Object?> payload;

  PendingOperation copyWith({
    OperationState? state,
    int? retryCount,
    Map<String, Object?>? payload,
  }) => PendingOperation(
    id: id,
    kind: kind,
    entityId: entityId,
    createdAt: createdAt,
    state: state ?? this.state,
    retryCount: retryCount ?? this.retryCount,
    payload: payload ?? this.payload,
  );
}

class AppPreferences {
  const AppPreferences({
    this.onboardingComplete = false,
    this.radiusKm = 2,
    this.isAvailableEvenings = true,
  });

  final bool onboardingComplete;
  final int radiusKm;
  final bool isAvailableEvenings;

  AppPreferences copyWith({
    bool? onboardingComplete,
    int? radiusKm,
    bool? isAvailableEvenings,
  }) => AppPreferences(
    onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    radiusKm: radiusKm ?? this.radiusKm,
    isAvailableEvenings: isAvailableEvenings ?? this.isAvailableEvenings,
  );
}
