import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sitaara/core/models/api_models.dart';
import 'package:sitaara/core/providers.dart';
import 'package:sitaara/core/storage/token_store.dart';
import 'package:sitaara/features/auth/application/session_controller.dart';
import 'package:sitaara/features/auth/data/auth_repository.dart';

void main() {
  test('restore without saved tokens becomes signed out', () async {
    final store = _MemoryTokenStore(null);
    final container = ProviderContainer(
      overrides: [tokenStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);

    container.read(sessionControllerProvider);
    await _waitFor(container, (state) => state.phase == SessionPhase.signedOut);

    expect(
      container.read(sessionControllerProvider).phase,
      SessionPhase.signedOut,
    );
  });

  test('restore loads an onboarded saved session', () async {
    final store = _MemoryTokenStore(_tokens);
    final repository = _AuthRepositoryStub(
      meResult: const MeModel(
        id: 'user-1',
        email: 'parent@example.test',
        onboardingState: 'onboarded',
      ),
    );
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(store),
        authRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    container.read(sessionControllerProvider);
    await _waitFor(container, (state) => state.phase == SessionPhase.onboarded);

    expect(
      container.read(sessionControllerProvider).me?.email,
      'parent@example.test',
    );
    expect(store.tokens, isNotNull);
  });

  test('unauthorized restore clears tokens and becomes signed out', () async {
    final store = _MemoryTokenStore(_tokens);
    final repository = _AuthRepositoryStub(
      meError: const ApiException(
        code: 'UNAUTHORIZED',
        message: 'Please sign in again.',
        statusCode: 401,
      ),
    );
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(store),
        authRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    container.read(sessionControllerProvider);
    await _waitFor(container, (state) => state.phase == SessionPhase.signedOut);

    expect(store.tokens, isNull);
  });

  test('login reconciles onboarding state with current user', () async {
    final store = _MemoryTokenStore(null);
    final repository = _AuthRepositoryStub(
      loginResult: _session,
      meResult: const MeModel(
        id: 'user-1',
        email: 'parent@example.test',
        onboardingState: 'onboarded',
      ),
    );
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(store),
        authRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    container.read(sessionControllerProvider);
    await _waitFor(container, (state) => state.phase == SessionPhase.signedOut);
    await container
        .read(sessionControllerProvider.notifier)
        .login(email: 'parent@example.test', password: 'password 123');

    expect(
      container.read(sessionControllerProvider).phase,
      SessionPhase.onboarded,
    );
    expect(store.tokens?.accessToken, _tokens.accessToken);
    expect(store.tokens?.refreshToken, _tokens.refreshToken);
  });
}

const _tokens = StoredTokens(
  accessToken: 'saved-access',
  refreshToken: 'saved-refresh',
);

final _session = SessionModel(
  user: UserModel(id: 'user-1', email: 'parent@example.test'),
  onboardingState: 'needs_family',
  accessToken: 'saved-access',
  refreshToken: 'saved-refresh',
  accessTokenExpiresAt: DateTime.utc(2030),
  refreshTokenExpiresAt: DateTime.utc(2030, 2),
);

Future<void> _waitFor(
  ProviderContainer container,
  bool Function(SessionState state) condition,
) async {
  for (var i = 0; i < 20; i++) {
    if (condition(container.read(sessionControllerProvider))) return;
    await Future<void>.delayed(Duration.zero);
  }
  fail('Session controller did not reach the expected state.');
}

class _MemoryTokenStore implements TokenStore {
  _MemoryTokenStore(this.tokens);

  StoredTokens? tokens;

  @override
  Future<void> clear() async => tokens = null;

  @override
  Future<StoredTokens?> read() async => tokens;

  @override
  Future<void> write(StoredTokens value) async => tokens = value;
}

class _AuthRepositoryStub implements AuthRepository {
  const _AuthRepositoryStub({this.meResult, this.meError, this.loginResult});

  final MeModel? meResult;
  final ApiException? meError;
  final SessionModel? loginResult;

  @override
  Future<MeModel> me() async {
    if (meError case final error?) throw error;
    return meResult!;
  }

  @override
  Future<SessionModel> login({
    required String email,
    required String password,
  }) async => loginResult!;

  @override
  Future<void> logout(StoredTokens tokens) async {}

  @override
  Future<SessionModel> register({
    required String email,
    required String password,
  }) => throw UnimplementedError();
}
