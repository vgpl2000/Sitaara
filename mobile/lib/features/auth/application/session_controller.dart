import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/api_models.dart';
import '../../../core/providers.dart';
import '../../../core/storage/token_store.dart';

enum SessionPhase { loading, signedOut, needsFamily, onboarded, restoreFailed }

class SessionState {
  const SessionState({
    required this.phase,
    this.me,
    this.isSubmitting = false,
    this.message,
  });

  const SessionState.loading() : this(phase: SessionPhase.loading);
  const SessionState.signedOut() : this(phase: SessionPhase.signedOut);

  final SessionPhase phase;
  final MeModel? me;
  final bool isSubmitting;
  final String? message;

  SessionState copyWith({
    SessionPhase? phase,
    MeModel? me,
    bool? isSubmitting,
    String? message,
  }) => SessionState(
    phase: phase ?? this.phase,
    me: me ?? this.me,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    message: message,
  );
}

final sessionControllerProvider =
    NotifierProvider<SessionController, SessionState>(SessionController.new);

class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() {
    final subscription = ref
        .read(apiClientProvider)
        .sessionExpired
        .listen((_) => unawaited(signOutLocally()));
    ref.onDispose(subscription.cancel);
    Future.microtask(restore);
    return const SessionState.loading();
  }

  Future<void> restore() async {
    state = const SessionState.loading();
    final tokens = await ref.read(tokenStoreProvider).read();
    if (tokens == null) {
      state = const SessionState.signedOut();
      return;
    }
    try {
      await _loadMe();
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        await ref.read(tokenStoreProvider).clear();
        state = const SessionState.signedOut();
      } else {
        state = SessionState(
          phase: SessionPhase.restoreFailed,
          message: error.message,
        );
      }
    }
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isSubmitting: true);
    try {
      final session = await ref
          .read(authRepositoryProvider)
          .register(email: email, password: password);
      await _acceptSession(session);
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isSubmitting: true);
    try {
      final session = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      await _acceptSession(session);
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  Future<void> _acceptSession(SessionModel session) async {
    await ref
        .read(tokenStoreProvider)
        .write(
          StoredTokens(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken,
          ),
        );
    state = SessionState(
      phase: session.onboardingState == 'onboarded'
          ? SessionPhase.onboarded
          : SessionPhase.needsFamily,
      me: MeModel(
        id: session.user.id,
        email: session.user.email,
        onboardingState: session.onboardingState,
      ),
    );
    // The current-user endpoint is authoritative because family membership may
    // have changed since an older API build created the login response.
    await _loadMe();
  }

  Future<void> familyChanged() => _loadMe();

  Future<void> _loadMe() async {
    final me = await ref.read(authRepositoryProvider).me();
    state = SessionState(
      phase: me.onboardingState == 'onboarded'
          ? SessionPhase.onboarded
          : SessionPhase.needsFamily,
      me: me,
    );
  }

  Future<void> logout() async {
    final store = ref.read(tokenStoreProvider);
    final tokens = await store.read();
    if (tokens != null) await ref.read(authRepositoryProvider).logout(tokens);
    await store.clear();
    state = const SessionState.signedOut();
  }

  Future<void> signOutLocally() async {
    await ref.read(tokenStoreProvider).clear();
    state = const SessionState.signedOut();
  }
}
