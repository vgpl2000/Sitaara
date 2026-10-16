import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sitaara/app/app.dart';
import 'package:sitaara/core/models/api_models.dart';
import 'package:sitaara/features/auth/application/session_controller.dart';
import 'package:sitaara/features/content/application/content_providers.dart';

void main() {
  testWidgets('loading state remains on the launch screen', (tester) async {
    await tester.pumpWidget(_app(const SessionState.loading()));
    await tester.pump();
    expect(find.text('Getting things ready…'), findsOneWidget);
  });

  testWidgets('signed-out state routes launch to Welcome', (tester) async {
    await tester.pumpWidget(_app(const SessionState.signedOut()));
    await tester.pumpAndSettle();
    expect(find.textContaining('Parenting feels lighter'), findsOneWidget);
  });

  testWidgets('needs-family state routes launch to onboarding', (tester) async {
    await tester.pumpWidget(
      _app(const SessionState(phase: SessionPhase.needsFamily)),
    );
    await tester.pumpAndSettle();
    expect(find.text('How would you like to begin?'), findsOneWidget);
  });

  testWidgets('onboarded state routes launch to the library', (tester) async {
    await tester.pumpWidget(
      _app(
        const SessionState(
          phase: SessionPhase.onboarded,
          me: MeModel(
            id: 'user-1',
            email: 'parent@example.test',
            onboardingState: 'onboarded',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Your learning'), findsOneWidget);
    expect(find.text('Masterclasses'), findsOneWidget);
  });
}

Widget _app(SessionState state) => ProviderScope(
  overrides: [
    sessionControllerProvider.overrideWith(
      () => _FixedSessionController(state),
    ),
    masterclassesProvider.overrideWith((ref) async => const []),
  ],
  child: const SitaaraApp(),
);

class _FixedSessionController extends SessionController {
  _FixedSessionController(this.fixedState);

  final SessionState fixedState;

  @override
  SessionState build() => fixedState;
}
