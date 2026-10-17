import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/page_frame.dart';
import '../../../core/widgets/sitaara_illustration.dart';
import '../../auth/application/session_controller.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final me = session.me;
    final family = me?.family;
    final ownRole = family?.ownRole == 'mom' ? 'Mom' : 'Dad';
    final partner = family?.partnerRole == null
        ? 'Waiting to be linked'
        : family!.partnerRole == 'mom'
        ? 'Mom'
        : 'Dad';

    return PageFrame(
      appBar: AppBar(title: const Text('Your space')),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF6C51B9)],
              ),
              borderRadius: BorderRadius.circular(34),
            ),
            child: Column(
              children: [
                const SitaaraIllustration(
                  'account_family',
                  height: 126,
                  semanticLabel: 'Your family on Sitaara',
                ),
                Text(
                  family == null
                      ? 'Your Sitaara account'
                      : '${family.child.name}’s parenting team',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  me?.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: Colors.white.withValues(alpha: .78)),
                ),
              ],
            ),
          ),
          if (family != null) ...[
            const SizedBox(height: 28),
            Text(
              'Family at a glance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _DetailStrip(
              color: AppColors.primarySoft,
              eyebrow: 'YOU',
              title: ownRole,
              detail: 'Learning and showing up for ${family.child.name}',
            ),
            const SizedBox(height: 10),
            _DetailStrip(
              color: AppColors.greenSoft,
              eyebrow: 'CO-PARENT',
              title: partner,
              detail: family.partnerRole == null
                  ? 'Invite your partner from the library when you’re ready.'
                  : 'Progress is shared across every masterclass.',
            ),
          ],
          const SizedBox(height: 30),
          Text(
            'About this build',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Securely connected to ${Uri.parse(AppConfig.apiBaseUrl).host}.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          OutlinedButton(
            onPressed: session.isSubmitting
                ? null
                : () => ref.read(sessionControllerProvider.notifier).logout(),
            child: const Text('Log out of this device'),
          ),
        ],
      ),
    );
  }
}

class _DetailStrip extends StatelessWidget {
  const _DetailStrip({
    required this.color,
    required this.eyebrow,
    required this.title,
    required this.detail,
  });

  final Color color;
  final String eyebrow;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(26),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: AppColors.primary, letterSpacing: .9),
        ),
        const SizedBox(height: 3),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 3),
        Text(detail),
      ],
    ),
  );
}
