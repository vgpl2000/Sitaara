import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/sitaara_illustration.dart';
import '../../../core/widgets/sitaara_logo.dart';
import '../../../core/widgets/skeleton.dart';
import '../../auth/application/session_controller.dart';
import '../application/content_providers.dart';
import '../data/content_models.dart';
import 'content_widgets.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final family = ref.watch(sessionControllerProvider).me?.family;
    final library = ref.watch(masterclassesProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const SitaaraLogo(onDark: true, width: 132),
        actions: [
          IconButton(
            tooltip: 'Your account',
            onPressed: () => context.push('/account'),
            icon: const Icon(Icons.account_circle_outlined, size: 29),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.canvas,
              AppColors.primarySoft,
              AppColors.greenSoft,
            ],
          ),
        ),
        child: SafeArea(
          child: library.when(
            loading: () => const ContentListSkeleton(),
            error: (error, stack) => ContentError(
              error: error,
              onRetry: () => ref.invalidate(masterclassesProvider),
            ),
            data: (items) => RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(sessionControllerProvider.notifier)
                    .familyChanged();
                ref.invalidate(masterclassesProvider);
                await ref.read(masterclassesProvider.future);
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 36),
                children: [
                  if (family != null)
                    _ChildGreeting(
                      name: family.child.name,
                      dateOfBirth: family.child.dateOfBirth,
                    )
                  else
                    Text(
                      'Your learning',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  const SizedBox(height: 20),
                  _PartnerNote(partnerRole: family?.partnerRole),
                  const SizedBox(height: 30),
                  Text(
                    'Made for this season',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Short, expert-led lessons to make the everyday feel easier.',
                  ),
                  const SizedBox(height: 16),
                  if (items.isEmpty)
                    const _EmptyLibrary()
                  else
                    for (final item in items) ...[
                      _MasterclassTile(item: item),
                      const SizedBox(height: 20),
                    ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChildGreeting extends StatelessWidget {
  const _ChildGreeting({required this.name, required this.dateOfBirth});

  final String name;
  final DateTime dateOfBirth;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Growing with $name',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 5),
            Text('${childAgeLabel(dateOfBirth)} old · guidance that grows too'),
          ],
        ),
      ),
      const SizedBox(width: 10),
      SitaaraIllustration(
        childIllustrationFor(dateOfBirth),
        height: 92,
        semanticLabel: 'Illustration for ${childAgeLabel(dateOfBirth)} child',
      ),
    ],
  );
}

class _PartnerNote extends StatelessWidget {
  const _PartnerNote({this.partnerRole});

  final String? partnerRole;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: partnerRole == null ? AppColors.yellowSoft : AppColors.primarySoft,
      borderRadius: BorderRadius.circular(28),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          partnerRole == null ? 'Make it a team journey' : 'SHARED FAMILY VIEW',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.primary,
            letterSpacing: partnerRole == null ? 0 : .8,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          partnerRole == null
              ? 'Invite your partner and see each other’s learning progress.'
              : 'You and ${roleLabel(partnerRole!)} can see each other’s likes and lesson progress here.',
        ),
        if (partnerRole == null) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonal(
              onPressed: () => context.push('/invite'),
              child: const Text('Create a private invite'),
            ),
          ),
        ],
      ],
    ),
  );
}

class _MasterclassTile extends StatelessWidget {
  const _MasterclassTile({required this.item});

  final MasterclassCardModel item;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '${item.title}, ${item.me.percent}% complete',
    child: Material(
      color: const Color(0xE6FFFFFF),
      borderRadius: BorderRadius.circular(30),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/masterclasses/${item.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NetworkArtwork(
              url: item.thumbnailUrl,
              borderRadius: BorderRadius.zero,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.videoCount} gentle lessons · ${durationLabel(item.totalDurationSeconds)}',
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: item.me.percent / 100,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text('You’re ${item.me.percent}% through this masterclass.'),
                  if (item.partner case final partner?) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${roleLabel(partner.role)} has finished ${partner.completedVideos} of ${item.videoCount} lessons${partner.isCurrentlyWatching ? ' and is learning now.' : '.'}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    'Open masterclass  →',
                    style: Theme.of(context).textTheme.labelLarge
                        ?.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppColors.yellowSoft,
      borderRadius: BorderRadius.circular(28),
    ),
    child: const Text('New guidance is on its way. Pull down to check again.'),
  );
}
