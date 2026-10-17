import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/page_frame.dart';
import '../../../core/widgets/sitaara_illustration.dart';

class FamilyPathScreen extends StatelessWidget {
  const FamilyPathScreen({super.key});

  @override
  Widget build(BuildContext context) => PageFrame(
    appBar: AppBar(title: const Text('Your family space')),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: SitaaraIllustration(
            'family_path',
            height: 164,
            semanticLabel: 'Two parents connected as one team',
          ),
        ),
        Text(
          'Let’s bring your parenting team together',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        const Text(
          'One parent creates the child profile. The other joins with a private six-character code.',
        ),
        const SizedBox(height: 28),
        _PathChoice(
          number: '01',
          color: AppColors.primarySoft,
          title: 'I’ll create our family',
          description: 'Add your child, then invite your partner.',
          onTap: () => context.go('/create-family'),
        ),
        const SizedBox(height: 14),
        _PathChoice(
          number: '02',
          color: AppColors.greenSoft,
          title: 'I have an invite code',
          description: 'Join the family space your partner created.',
          onTap: () => context.go('/join-family'),
        ),
      ],
    ),
  );
}

class _PathChoice extends StatelessWidget {
  const _PathChoice({
    required this.number,
    required this.color,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final String number;
  final Color color;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: Material(
      color: color,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Text(
                number,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(color: AppColors.primary),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(description),
                  ],
                ),
              ),
              const Text('→', style: TextStyle(fontSize: 28)),
            ],
          ),
        ),
      ),
    ),
  );
}
