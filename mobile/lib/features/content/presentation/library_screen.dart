import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/sitaara_logo.dart';
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
            tooltip: 'Account',
            onPressed: () => context.push('/account'),
            icon: const Icon(
              Icons.account_circle_outlined,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: library.when(
          loading: () => const Center(child: CircularProgressIndicator()),
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                Text(
                  family == null ? 'Your learning' : 'For ${family.child.name}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if (family != null) ...[
                  const SizedBox(height: 4),
                  Text('${childAgeLabel(family.child.dateOfBirth)} old'),
                ],
                const SizedBox(height: 20),
                _PartnerCard(partnerRole: family?.partnerRole),
                const SizedBox(height: 28),
                Text(
                  'Masterclasses',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 14),
                if (items.isEmpty)
                  const _EmptyLibrary()
                else
                  for (final item in items) ...[
                    _MasterclassCard(item: item),
                    const SizedBox(height: 18),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  const _PartnerCard({this.partnerRole});

  final String? partnerRole;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primarySoft,
            foregroundColor: AppColors.primary,
            child: Icon(Icons.people_outline),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  partnerRole == null
                      ? 'Invite your partner'
                      : 'Learning together with ${roleLabel(partnerRole!)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  partnerRole == null
                      ? 'Share a secure code and learn as a team.'
                      : 'Your shared progress appears on every lesson.',
                ),
                if (partnerRole == null) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => context.push('/invite'),
                    icon: const Icon(Icons.link),
                    label: const Text('Create invite'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _MasterclassCard extends StatelessWidget {
  const _MasterclassCard({required this.item});

  final MasterclassCardModel item;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '${item.title}, ${item.me.percent}% complete',
    child: Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/masterclasses/${item.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NetworkArtwork(url: item.thumbnailUrl),
              const SizedBox(height: 14),
              Text(item.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                '${item.videoCount} videos · ${durationLabel(item.totalDurationSeconds)}',
              ),
              const SizedBox(height: 10),
              Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: item.me.percent / 100,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('${item.me.percent}%'),
                ],
              ),
              if (item.partner case final partner?) ...[
                const SizedBox(height: 10),
                Text(
                  '${roleLabel(partner.role)} · ${partner.percent}% · ${partner.completedVideos}/${item.videoCount} complete${partner.isCurrentlyWatching ? ' · Watching now' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary();

  @override
  Widget build(BuildContext context) => const Card(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Text('No masterclasses are available yet. Pull down to refresh.'),
    ),
  );
}
