import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/sitaara_logo.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.primary,
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SitaaraLogo(onDark: true, width: 180),
                  const Spacer(),
                  Text(
                    'Parenting feels lighter when you learn together.',
                    style: Theme.of(context).textTheme.displaySmall
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Share practical guidance, celebrate progress, and stay connected as a parenting team.',
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                  ),
                  const SizedBox(height: 36),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                    ),
                    onPressed: () => context.go('/signup'),
                    child: const Text('Create account'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                    ),
                    onPressed: () => context.go('/login'),
                    child: const Text('Log in'),
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
