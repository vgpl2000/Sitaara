import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../application/content_providers.dart';
import '../data/content_models.dart';
import 'content_widgets.dart';

class MasterclassScreen extends ConsumerWidget {
  const MasterclassScreen({super.key, required this.masterclassId});

  final String masterclassId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(masterclassProvider(masterclassId));
    return Scaffold(
      appBar: AppBar(title: const Text('Masterclass')),
      body: SafeArea(
        child: detail.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => ContentError(
            error: error,
            onRetry: () => ref.invalidate(masterclassProvider(masterclassId)),
          ),
          data: (item) => RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(masterclassProvider(masterclassId));
              await ref.read(masterclassProvider(masterclassId).future);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                NetworkArtwork(url: item.thumbnailUrl, height: 200),
                const SizedBox(height: 20),
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(item.description),
                const SizedBox(height: 18),
                _Summary(item: item),
                const SizedBox(height: 26),
                Text(
                  'Lessons',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                for (final video in item.videos) ...[
                  _VideoRow(video: video),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.item});

  final MasterclassDetailModel item;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _SummaryCard(
          label: 'You',
          value: '${item.me.percent}%',
          detail: '${item.me.completedVideos}/${item.videos.length} complete',
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: item.partner == null
            ? const _SummaryCard(
                label: 'Partner',
                value: 'Not linked',
                detail: 'Invite from Home',
              )
            : _SummaryCard(
                label: roleLabel(item.partner!.role),
                value: '${item.partner!.percent}%',
                detail:
                    '${item.partner!.completedVideos}/${item.videos.length} complete',
              ),
      ),
    ],
  );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.detail,
  });

  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 2),
          Text(detail, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    ),
  );
}

class _VideoRow extends StatelessWidget {
  const _VideoRow({required this.video});

  final VideoModel video;

  @override
  Widget build(BuildContext context) {
    final partner = video.partner;
    final ownStatus = video.me.completed
        ? 'Completed'
        : video.me.percent > 0
        ? '${video.me.percent}% watched'
        : 'Not started';
    final partnerStatus = partner == null
        ? null
        : partner.completed
        ? 'Completed by ${roleLabel(partner.role)}'
        : partner.percent > 0
        ? '${roleLabel(partner.role)} watched ${partner.percent}%'
        : '${roleLabel(partner.role)} has not started';
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/videos/${video.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 92,
                  child: NetworkArtwork(
                    url: video.thumbnailUrl,
                    height: 76,
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${durationLabel(video.durationSeconds)} · $ownStatus',
                    ),
                    if (partnerStatus != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        partnerStatus,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              if (video.me.liked)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.favorite, color: AppColors.primary),
                )
              else
                const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
