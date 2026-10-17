import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/sitaara_illustration.dart';
import '../../../core/widgets/sitaara_logo.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, Color(0xFF5C43A8), Color(0xFF806CC1)],
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 44,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SitaaraLogo(onDark: true, width: 152),
                  const SizedBox(height: 24),
                  const Center(
                    child: SitaaraIllustration(
                      'welcome_family',
                      height: 235,
                      semanticLabel: 'A family learning together',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Parenthood, without the overwhelm.',
                    style: Theme.of(context).textTheme.displaySmall
                        ?.copyWith(color: AppColors.yellow, height: 1.12),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Trusted lessons and shared progress, so you and your partner can grow together.',
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: Colors.white.withValues(alpha: .9)),
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.yellow,
                      foregroundColor: AppColors.primary,
                    ),
                    onPressed: () => context.go('/signup'),
                    child: const Text('Start your family journey'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 1.4),
                    ),
                    onPressed: () => context.go('/login'),
                    child: const Text('I already have an account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
