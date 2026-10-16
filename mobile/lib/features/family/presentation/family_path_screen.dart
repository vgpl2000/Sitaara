import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/page_frame.dart';

class FamilyPathScreen extends StatelessWidget {
  const FamilyPathScreen({super.key});

  @override
  Widget build(BuildContext context) => PageFrame(
    appBar: AppBar(title: const Text('Set up your family')),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How would you like to begin?',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        const Text(
          'One parent creates the shared child profile. The second parent joins with a six-character invite code.',
        ),
        const SizedBox(height: 28),
        _ChoiceCard(
          icon: Icons.family_restroom,
          title: 'Create a family',
          description: 'Add your child once, then invite your partner.',
          onTap: () => context.go('/create-family'),
        ),
        const SizedBox(height: 16),
        _ChoiceCard(
          icon: Icons.link,
          title: 'Join your partner',
          description: 'Use the invite code your partner shared with you.',
          onTap: () => context.go('/join-family'),
        ),
      ],
    ),
  );
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
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
            const Icon(Icons.arrow_forward_ios, size: 18),
          ],
        ),
      ),
    ),
  );
}
