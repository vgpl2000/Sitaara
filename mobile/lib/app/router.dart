import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/account/presentation/account_screen.dart';
import '../features/auth/application/session_controller.dart';
import '../features/auth/presentation/auth_form_screen.dart';
import '../features/auth/presentation/launch_screen.dart';
import '../features/auth/presentation/welcome_screen.dart';
import '../features/family/presentation/create_family_screen.dart';
import '../features/family/presentation/family_path_screen.dart';
import '../features/family/presentation/invite_screen.dart';
import '../features/family/presentation/join_family_screen.dart';
import '../features/content/presentation/library_screen.dart';
import '../features/content/presentation/masterclass_screen.dart';
import '../features/content/presentation/video_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionControllerProvider);
  return GoRouter(
    initialLocation: '/launch',
    redirect: (context, route) {
      final path = route.matchedLocation;
      switch (session.phase) {
        case SessionPhase.loading:
        case SessionPhase.restoreFailed:
          return path == '/launch' ? null : '/launch';
        case SessionPhase.signedOut:
          return const {'/welcome', '/login', '/signup'}.contains(path)
              ? null
              : '/welcome';
        case SessionPhase.needsFamily:
          return const {
                '/onboarding',
                '/create-family',
                '/join-family',
              }.contains(path)
              ? null
              : '/onboarding';
        case SessionPhase.onboarded:
          return const {
                '/launch',
                '/welcome',
                '/login',
                '/signup',
                '/onboarding',
                '/create-family',
                '/join-family',
              }.contains(path)
              ? '/library'
              : null;
      }
    },
    routes: [
      GoRoute(
        path: '/launch',
        builder: (context, state) => const LaunchScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) =>
            const AuthFormScreen(mode: AuthMode.signup),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const AuthFormScreen(mode: AuthMode.login),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const FamilyPathScreen(),
      ),
      GoRoute(
        path: '/create-family',
        builder: (context, state) => const CreateFamilyScreen(),
      ),
      GoRoute(
        path: '/join-family',
        builder: (context, state) => const JoinFamilyScreen(),
      ),
      GoRoute(
        path: '/library',
        builder: (context, state) => const LibraryScreen(),
      ),
      GoRoute(
        path: '/masterclasses/:masterclassId',
        builder: (context, state) => MasterclassScreen(
          masterclassId: state.pathParameters['masterclassId']!,
        ),
      ),
      GoRoute(
        path: '/videos/:videoId',
        builder: (context, state) =>
            VideoScreen(videoId: state.pathParameters['videoId']!),
      ),
      GoRoute(
        path: '/invite',
        builder: (context, state) => const InviteScreen(),
      ),
      GoRoute(
        path: '/account',
        builder: (context, state) => const AccountScreen(),
      ),
    ],
  );
});
