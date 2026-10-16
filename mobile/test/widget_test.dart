import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sitaara/core/theme/app_theme.dart';
import 'package:sitaara/features/auth/presentation/welcome_screen.dart';

void main() {
  testWidgets('welcome screen presents both authentication paths', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [GoRoute(path: '/', builder: (_, _) => const WelcomeScreen())],
    );
    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );

    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.textContaining('Parenting feels lighter'), findsOneWidget);
  });
}
