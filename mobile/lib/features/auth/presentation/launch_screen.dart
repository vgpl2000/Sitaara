import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/sitaara_logo.dart';
import '../application/session_controller.dart';

class LaunchScreen extends ConsumerWidget {
  const LaunchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SitaaraLogo(width: 190),
                const SizedBox(height: 32),
                if (session.phase == SessionPhase.restoreFailed) ...[
                  const Icon(Icons.cloud_off_outlined, size: 42),
                  const SizedBox(height: 16),
                  Text(
                    session.message ?? 'We could not restore your session.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () =>
                        ref.read(sessionControllerProvider.notifier).restore(),
                    child: const Text('Retry'),
                  ),
                  TextButton(
                    onPressed: () => ref
                        .read(sessionControllerProvider.notifier)
                        .signOutLocally(),
                    child: const Text('Sign out on this device'),
                  ),
                ] else ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Getting things ready…'),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
