import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../domain/models.dart';
import 'local_store.dart';

abstract interface class RemoteTransport {
  Future<void> send(PendingOperation operation);
}

/// A deterministic seam for replacing with a Supabase transport later.
class MockRemoteTransport implements RemoteTransport {
  @override
  Future<void> send(PendingOperation operation) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }
}

class ConnectivityService {
  ConnectivityService(this._connectivity);
  final Connectivity _connectivity;

  Stream<AppConnectionState> watch() => _connectivity.onConnectivityChanged.map(
    (results) => results.contains(ConnectivityResult.none)
        ? AppConnectionState.offline
        : AppConnectionState.online,
  );
}

/// Local-first repository: UI observes its streams while all mutations first
/// update local state, persist an outbox item, then reconcile when online.
class SkillRepository {
  SkillRepository({
    required DriftLocalStore localStore,
    required PreferencesStore preferencesStore,
    required RemoteTransport transport,
  }) : _localStore = localStore,
       _preferencesStore = preferencesStore,
       _transport = transport;

  final DriftLocalStore _localStore;
  final PreferencesStore _preferencesStore;
  final RemoteTransport _transport;

  final _profiles = _StreamValue<List<SkillProfile>>(_seedProfiles);
  final _requests = _StreamValue<List<SwapRequest>>(_seedRequests);
  final _messages = _StreamValue<List<ChatMessage>>(_seedMessages);
  final _outbox = _StreamValue<List<PendingOperation>>(const []);
  final _connection = _StreamValue<AppConnectionState>(
    AppConnectionState.online,
  );
  late final _preferences = _StreamValue<AppPreferences>(
    _preferencesStore.read(),
  );

  final _myProfile = _StreamValue<SkillProfile>(
    const SkillProfile(
      id: 'me',
      name: 'Aanya Sharma',
      initials: 'AS',
      distanceKm: 0.0,
      rating: 4.9,
      responseRate: 93,
      offers: ['Graphic Design', 'Branding', 'Canva'],
      wants: ['Guitar', 'Gardening'],
      bio: 'Passionate graphic designer and branding strategist.',
      isVerified: true,
    ),
  );

  Stream<List<SkillProfile>> watchProfiles() => _profiles.stream;
  Stream<SkillProfile> watchMyProfile() => _myProfile.stream;
  SkillProfile get myProfile => _myProfile.value;
  Stream<List<SwapRequest>> watchRequests() => _requests.stream;
  Stream<List<ChatMessage>> watchMessages() => _messages.stream;
  Stream<List<PendingOperation>> watchOutbox() => _outbox.stream;
  Stream<AppConnectionState> watchConnection() => _connection.stream;
  Stream<AppPreferences> watchPreferences() => _preferences.stream;
  AppPreferences get preferences => _preferences.value;
  List<PendingOperation> get pendingOperations =>
      List.unmodifiable(_outbox.value);
  List<SwapRequest> get currentRequests => List.unmodifiable(_requests.value);

  SkillProfile profile(String id) =>
      _profiles.value.firstWhere((profile) => profile.id == id);

  Future<void> completeOnboarding() =>
      _savePreferences(_preferences.value.copyWith(onboardingComplete: true));
  Future<void> setRadius(int radius) =>
      _savePreferences(_preferences.value.copyWith(radiusKm: radius));
  Future<void> setAvailability(bool evenings) => _savePreferences(
    _preferences.value.copyWith(isAvailableEvenings: evenings),
  );

  Future<void> _savePreferences(AppPreferences preferences) async {
    _preferences.add(preferences);
    await _preferencesStore.write(preferences);
  }

  Future<void> setConnection(AppConnectionState value) async {
    _connection.add(value);
    if (value == AppConnectionState.online) await flushQueue();
  }

  Future<void> createSwapRequest({
    required String profileId,
    required String wantedSkill,
    required String offeredSkill,
    required String message,
    required String preferredTime,
  }) async {
    final id = 'request-${DateTime.now().microsecondsSinceEpoch}';
    final request = SwapRequest(
      id: id,
      profileId: profileId,
      wantedSkill: wantedSkill,
      offeredSkill: offeredSkill,
      message: message,
      preferredTime: preferredTime,
      status: RequestStatus.pending,
      isIncoming: false,
      isPendingSync: true,
    );
    _requests.add([..._requests.value, request]);
    await _localStore.cacheEntity(
      table: 'swap_requests',
      id: id,
      payload: _requestPayload(request),
    );
    await _enqueue(
      OperationKind.requestSwap,
      id,
      payload: {
        'profile_id': profileId,
        'wanted_skill': wantedSkill,
        'offered_skill': offeredSkill,
        'message': message,
        'preferred_time': preferredTime,
      },
    );
  }

  Future<void> sendMessage({
    required String profileId,
    required String body,
    DateTime? proposalDate,
    String? proposalLocation,
    String? offeredSkill,
    String? wantedSkill,
  }) async {
    final message = ChatMessage(
      id: 'message-${DateTime.now().microsecondsSinceEpoch}',
      profileId: profileId,
      body: body,
      sentByMe: true,
      timeLabel: 'Now',
      isPendingSync: true,
      proposalDate: proposalDate,
      proposalLocation: proposalLocation,
      proposalStatus: proposalLocation != null ? 'pending' : null,
      offeredSkill: offeredSkill,
      wantedSkill: wantedSkill,
    );
    _messages.add([..._messages.value, message]);
    await _localStore.cacheMessage(
      id: message.id,
      requestId: profileId,
      payload: body,
    );
    await _enqueue(
      OperationKind.sendMessage,
      message.id,
      payload: {'profile_id': profileId, 'body': body},
    );
  }

  Future<void> updateProposalStatus(String messageId, String status) async {
    _messages.add(
      _messages.value
          .map(
            (msg) => msg.id == messageId ? msg.copyWith(proposalStatus: status) : msg,
          )
          .toList(),
    );
  }

  Future<void> completeSwap(String requestId) async {
    _requests.add(
      _requests.value
          .map(
            (request) => request.id == requestId
                ? request.copyWith(
                    status: RequestStatus.completed,
                    isPendingSync: true,
                  )
                : request,
          )
          .toList(),
    );
    await _enqueue(OperationKind.completeSwap, requestId);
  }

  Future<void> submitSwapRating({
    required String requestId,
    required double rating,
    required String comment,
    required List<String> tags,
  }) async {
    await completeSwap(requestId);
    await _enqueue(
      OperationKind.submitRating,
      requestId,
      payload: {
        'rating': rating,
        'comment': comment,
        'tags': tags,
      },
    );
  }

  Future<void> updateUserProfile({
    required String name,
    required String bio,
    required List<String> offers,
    required List<String> wants,
    double? lat,
    double? lng,
    String? avatarUrl,
  }) async {
    final nameParts = name.trim().split(' ');
    final initials = nameParts.map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
    final updated = _myProfile.value.copyWith(
      name: name.trim().isNotEmpty ? name.trim() : _myProfile.value.name,
      initials: initials.isNotEmpty ? initials : _myProfile.value.initials,
      bio: bio.trim(),
      offers: offers,
      wants: wants,
      avatarUrl: avatarUrl ?? _myProfile.value.avatarUrl,
    );
    _myProfile.add(updated);

    await _enqueue(
      OperationKind.updateProfile,
      _myProfile.value.id,
      payload: {
        'name': updated.name,
        'bio': updated.bio,
        'offers': updated.offers,
        'wants': updated.wants,
        if (lat != null && lng != null) 'latitude': lat,
        if (lat != null && lng != null) 'longitude': lng,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      },
    );
  }

  Future<void> submitRating(String requestId) =>
      _enqueue(OperationKind.submitRating, requestId);

  Future<void> _enqueue(
    OperationKind kind,
    String entityId, {
    Map<String, Object?> payload = const {},
  }) async {
    final operation = PendingOperation(
      id: 'operation-${DateTime.now().microsecondsSinceEpoch}',
      kind: kind,
      entityId: entityId,
      createdAt: DateTime.now(),
      payload: payload,
    );
    _outbox.add([..._outbox.value, operation]);
    await _localStore.cacheOperation(operation);
    if (_connection.value == AppConnectionState.online) unawaited(flushQueue());
  }

  Future<void> flushQueue() async {
    if (_connection.value == AppConnectionState.offline) return;
    for (final operation in List<PendingOperation>.from(_outbox.value)) {
      try {
        await _transport.send(operation);
        _outbox.add(
          _outbox.value.where((item) => item.id != operation.id).toList(),
        );
        await _localStore.removeOperation(operation.id);
        _markEntitySynced(operation);
      } catch (_) {
        final failed = operation.copyWith(
          state: OperationState.failed,
          retryCount: operation.retryCount + 1,
        );
        _outbox.add(
          _outbox.value
              .map((item) => item.id == operation.id ? failed : item)
              .toList(),
        );
        await _localStore.cacheOperation(failed);
        break;
      }
    }
  }

  void _markEntitySynced(PendingOperation operation) {
    if (operation.kind == OperationKind.requestSwap ||
        operation.kind == OperationKind.completeSwap) {
      _requests.add(
        _requests.value
            .map(
              (item) => item.id == operation.entityId
                  ? item.copyWith(isPendingSync: false)
                  : item,
            )
            .toList(),
      );
    }
    if (operation.kind == OperationKind.sendMessage) {
      _messages.add(
        _messages.value
            .map(
              (item) => item.id == operation.entityId
                  ? item.copyWith(isPendingSync: false)
                  : item,
            )
            .toList(),
      );
    }
  }

  static String _requestPayload(SwapRequest request) =>
      '${request.wantedSkill}|${request.offeredSkill}|${request.message}';
}

class _StreamValue<T> {
  _StreamValue(this.value);
  T value;
  final _controller = StreamController<T>.broadcast();

  /// Riverpod may subscribe after fixture/cache hydration completes. Replay the
  /// latest local snapshot first so tabs never stay in a loading state solely
  /// because the initial event was emitted before their widget mounted.
  Stream<T> get stream async* {
    yield value;
    yield* _controller.stream;
  }

  void add(T next) {
    value = next;
    _controller.add(next);
  }
}

const _seedProfiles = <SkillProfile>[
  SkillProfile(
    id: 'rohan',
    name: 'Rohan Verma',
    initials: 'RV',
    distanceKm: 1.2,
    rating: 4.8,
    responseRate: 95,
    offers: ['Guitar Lessons', 'Music Theory', 'Ukulele'],
    wants: ['Photography', 'Video Editing'],
    bio: 'Passionate musician and teacher. Love helping people learn!',
    isVerified: true,
    hasVideo: true,
  ),
  SkillProfile(
    id: 'neha',
    name: 'Neha Patel',
    initials: 'NP',
    distanceKm: 1.5,
    rating: 4.9,
    responseRate: 92,
    offers: ['Yoga', 'Meditation', 'Wellness'],
    wants: ['Cooking', 'Gardening'],
    bio: 'Yoga teacher who loves a calm neighbourhood morning.',
  ),
  SkillProfile(
    id: 'arjun',
    name: 'Arjun Mehta',
    initials: 'AM',
    distanceKm: 1.8,
    rating: 4.7,
    responseRate: 88,
    offers: ['Video Editing', 'Adobe Premiere'],
    wants: ['Guitar Lessons'],
    bio: 'I turn local stories into thoughtful short films.',
  ),
  SkillProfile(
    id: 'maya',
    name: 'Maya Iyer',
    initials: 'MI',
    distanceKm: 2.4,
    rating: 5.0,
    responseRate: 98,
    offers: ['Sourdough Baking', 'Indian Cooking', 'Meal Planning'],
    wants: ['Watercolour', 'House Plants'],
    bio: 'Home baker with a spare starter and a soft spot for shared meals.',
    isVerified: true,
  ),
  SkillProfile(
    id: 'kabir',
    name: 'Kabir Singh',
    initials: 'KS',
    distanceKm: 2.8,
    rating: 4.6,
    responseRate: 90,
    offers: ['Cycle Repair', 'Furniture Fixes', 'Tool Advice'],
    wants: ['Spoken Spanish', 'Bread Baking'],
    bio: 'Weekend fixer. Happy to help a good thing last a little longer.',
  ),
  SkillProfile(
    id: 'sana',
    name: 'Sana Khan',
    initials: 'SK',
    distanceKm: 3.1,
    rating: 4.9,
    responseRate: 96,
    offers: ['Watercolour', 'Calligraphy', 'Sketching'],
    wants: ['Yoga', 'Guitar Lessons'],
    bio:
        'Illustrator, stationery enthusiast, and patient beginner-friendly teacher.',
    hasVideo: true,
  ),
];

const _seedRequests = <SwapRequest>[
  SwapRequest(
    id: 'incoming-rohan',
    profileId: 'rohan',
    wantedSkill: 'Graphic Design',
    offeredSkill: 'Guitar Lessons',
    message: 'Could you help with a small poster?',
    preferredTime: 'This weekend',
    status: RequestStatus.pending,
    isIncoming: true,
    isPendingSync: false,
  ),
  SwapRequest(
    id: 'incoming-maya',
    profileId: 'maya',
    wantedSkill: 'Graphic Design',
    offeredSkill: 'Sourdough Baking',
    message:
        'Could we trade a loaf-and-starter lesson for help with my menu card?',
    preferredTime: 'Saturday morning',
    status: RequestStatus.pending,
    isIncoming: true,
    isPendingSync: false,
  ),
  SwapRequest(
    id: 'outgoing-arjun',
    profileId: 'arjun',
    wantedSkill: 'Video Editing',
    offeredSkill: 'Graphic Design',
    message: 'Would love to swap a few editing basics for poster help.',
    preferredTime: 'Thursday evening',
    status: RequestStatus.pending,
    isIncoming: false,
    isPendingSync: false,
  ),
  SwapRequest(
    id: 'completed-kabir',
    profileId: 'kabir',
    wantedSkill: 'Cycle Repair',
    offeredSkill: 'Graphic Design',
    message: 'Thanks for rescuing my old bike!',
    preferredTime: 'Last weekend',
    status: RequestStatus.completed,
    isIncoming: false,
    isPendingSync: false,
  ),
  SwapRequest(
    id: 'completed-sana',
    profileId: 'sana',
    wantedSkill: 'Watercolour',
    offeredSkill: 'Graphic Design',
    message: 'A lovely Sunday sketch session at the café.',
    preferredTime: 'Two weeks ago',
    status: RequestStatus.completed,
    isIncoming: true,
    isPendingSync: false,
  ),
  SwapRequest(
    id: 'outgoing-neha',
    profileId: 'neha',
    wantedSkill: 'Yoga',
    offeredSkill: 'Graphic Design',
    message: 'I would love a gentle session.',
    preferredTime: 'Tuesday evening',
    status: RequestStatus.accepted,
    isIncoming: false,
    isPendingSync: false,
  ),
];

const _seedMessages = <ChatMessage>[
  ChatMessage(
    id: 'seed-1',
    profileId: 'rohan',
    body: 'Hey Aanya! Thanks for the request 🙂',
    sentByMe: false,
    timeLabel: '10:30 AM',
    isPendingSync: false,
  ),
  ChatMessage(
    id: 'seed-2',
    profileId: 'rohan',
    body: 'Hi Rohan! Excited to learn guitar from you.',
    sentByMe: true,
    timeLabel: '10:31 AM',
    isPendingSync: false,
  ),
  ChatMessage(
    id: 'seed-3',
    profileId: 'rohan',
    body: 'Shall we meet at the park tomorrow evening?',
    sentByMe: false,
    timeLabel: '10:33 AM',
    isPendingSync: false,
  ),
  ChatMessage(
    id: 'seed-neha-1',
    profileId: 'neha',
    body: 'Tuesday evening still works for me. Shall we meet by the garden?',
    sentByMe: false,
    timeLabel: 'Yesterday',
    isPendingSync: false,
  ),
  ChatMessage(
    id: 'seed-neha-2',
    profileId: 'neha',
    body: 'Perfect — I’ll bring a mat for you too.',
    sentByMe: true,
    timeLabel: 'Yesterday',
    isPendingSync: false,
  ),
  ChatMessage(
    id: 'seed-maya-1',
    profileId: 'maya',
    body: 'I just fed the starter — it will be ready for Saturday!',
    sentByMe: false,
    timeLabel: 'Mon',
    isPendingSync: false,
  ),
  ChatMessage(
    id: 'seed-arjun-1',
    profileId: 'arjun',
    body: 'I saved a few simple cuts for us to practise with.',
    sentByMe: false,
    timeLabel: 'Sun',
    isPendingSync: false,
  ),
];
