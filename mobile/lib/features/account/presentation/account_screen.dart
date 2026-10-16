import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/widgets/page_frame.dart';
import '../../auth/application/session_controller.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final me = session.me;
    final family = me?.family;
    return PageFrame(
      appBar: AppBar(title: const Text('Account')),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your account',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _Row(label: 'Email', value: me?.email ?? '—'),
                  if (family != null) ...[
                    const Divider(height: 28),
                    _Row(
                      label: 'Your role',
                      value: family.ownRole == 'mom' ? 'Mom' : 'Dad',
                    ),
                    const Divider(height: 28),
                    _Row(label: 'Child', value: family.child.name),
                    const Divider(height: 28),
                    _Row(
                      label: 'Partner',
                      value: family.partnerRole == null
                          ? 'Not linked'
                          : (family.partnerRole == 'mom' ? 'Mom' : 'Dad'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'API: ${AppConfig.apiBaseUrl}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: session.isSubmitting
                ? null
                : () => ref.read(sessionControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 96,
        child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ),
      Expanded(
        child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    ],
  );
}
