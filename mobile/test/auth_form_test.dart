import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sitaara/core/models/api_models.dart';
import 'package:sitaara/core/theme/app_theme.dart';
import 'package:sitaara/features/auth/application/session_controller.dart';
import 'package:sitaara/features/auth/presentation/auth_form_screen.dart';

void main() {
  testWidgets('signup form exposes required validation messages', (
    tester,
  ) async {
    await tester.pumpWidget(_formApp(_FormSessionController()));

    await tester.ensureVisible(find.byType(FilledButton));
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.text('Use at least 8 characters.'), findsOneWidget);
  });

  testWidgets('signup form displays safe API errors', (tester) async {
    await tester.pumpWidget(
      _formApp(
        _FormSessionController(
          registerError: const ApiException(
            code: 'EMAIL_ALREADY_USED',
            message: 'That email is already registered.',
          ),
        ),
      ),
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'parent@example.com');
    await tester.enterText(fields.at(1), 'password 123');
    await tester.enterText(fields.at(2), 'password 123');
    await tester.ensureVisible(find.byType(FilledButton));
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('That email is already registered.'), findsOneWidget);
  });

  testWidgets('signup form shows a loader while submitting', (tester) async {
    await tester.pumpWidget(
      _formApp(
        _FormSessionController(
          initial: const SessionState(
            phase: SessionPhase.signedOut,
            isSubmitting: true,
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}

Widget _formApp(_FormSessionController controller) => ProviderScope(
  overrides: [sessionControllerProvider.overrideWith(() => controller)],
  child: MaterialApp(
    theme: AppTheme.light,
    home: const AuthFormScreen(mode: AuthMode.signup),
  ),
);

class _FormSessionController extends SessionController {
  _FormSessionController({
    this.registerError,
    this.initial = const SessionState.signedOut(),
  });

  final ApiException? registerError;
  final SessionState initial;

  @override
  SessionState build() => initial;

  @override
  Future<void> register({
    required String email,
    required String password,
  }) async {
    if (registerError case final error?) throw error;
  }
}
