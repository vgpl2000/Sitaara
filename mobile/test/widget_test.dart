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

  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets('welcome remains usable at ${width.toInt()} logical pixels', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 700);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_welcomeApp());
      expect(tester.takeException(), isNull);
      expect(find.text('Create account'), findsOneWidget);
      expect(find.text('Log in'), findsOneWidget);
    });
  }

  testWidgets('welcome keeps required actions at large text size', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      _welcomeApp(textScaler: const TextScaler.linear(2)),
    );
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Log in'));
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });
}

Widget _welcomeApp({TextScaler? textScaler}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [GoRoute(path: '/', builder: (_, _) => const WelcomeScreen())],
  );
  return MaterialApp.router(
    theme: AppTheme.light,
    routerConfig: router,
    builder: textScaler == null
        ? null
        : (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: textScaler),
            child: child!,
          ),
  );
}
