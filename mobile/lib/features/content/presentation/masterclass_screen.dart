import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/skeleton.dart';
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
      appBar: AppBar(
        leadingWidth: 82,
        leading: TextButton(
          onPressed: () => context.go('/library'),
          child: const Text('← Back'),
        ),
        title: const Text('Masterclass'),
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
          child: detail.when(
            loading: () => const ContentListSkeleton(),
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
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
                children: [
                  NetworkArtwork(url: item.thumbnailUrl, height: 206),
                  const SizedBox(height: 20),
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(item.description),
                  const SizedBox(height: 20),
                  _ProgressStory(item: item),
                  const SizedBox(height: 28),
                  Text(
                    'Your lesson path',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 5),
                  const Text('Take it one small idea at a time.'),
                  const SizedBox(height: 12),
                  for (var index = 0; index < item.videos.length; index++) ...[
                    _VideoRow(number: index + 1, video: item.videos[index]),
                    const SizedBox(height: 10),
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

class _ProgressStory extends StatelessWidget {
  const _ProgressStory({required this.item});

  final MasterclassDetailModel item;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.primarySoft,
      borderRadius: BorderRadius.circular(28),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Learning together',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        _ProgressLine(
          label: 'You',
          percent: item.me.percent,
          detail: '${item.me.completedVideos}/${item.videos.length} complete',
        ),
        const SizedBox(height: 14),
        _ProgressLine(
          label: item.partner == null
              ? 'Your partner'
              : roleLabel(item.partner!.role),
          percent: item.partner?.percent ?? 0,
          detail: item.partner == null
              ? 'Invite them from the library'
              : '${item.partner!.completedVideos}/${item.videos.length} complete${item.partner!.isCurrentlyWatching ? ' · Learning now' : ''}',
          partner: true,
        ),
      ],
    ),
  );
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({
    required this.label,
    required this.percent,
    required this.detail,
    this.partner = false,
  });
  final String label;
  final int percent;
  final String detail;
  final bool partner;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text('$percent%'),
        ],
      ),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: LinearProgressIndicator(
          value: percent / 100,
          minHeight: 8,
          color: partner ? AppColors.green : AppColors.primary,
          backgroundColor: Colors.white.withValues(alpha: .7),
        ),
      ),
      const SizedBox(height: 4),
      Text(detail, style: Theme.of(context).textTheme.bodyMedium),
    ],
  );
}

class _VideoRow extends StatelessWidget {
  const _VideoRow({required this.number, required this.video});
  final int number;
  final VideoModel video;

  @override
  Widget build(BuildContext context) {
    final ownStatus = video.me.completed
        ? 'Completed'
        : video.me.percent > 0
        ? '${video.me.percent}% watched'
        : 'Ready when you are';
    final partner = video.partner;
    final partnerStatus = partner == null
        ? null
        : partner.completed
        ? '${roleLabel(partner.role)} completed this'
        : partner.percent > 0
        ? '${roleLabel(partner.role)} watched ${partner.percent}%'
        : null;
    return Material(
      color: const Color(0xD9FFFFFF),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.push('/videos/${video.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.yellowSoft,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$number',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
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
                    const SizedBox(height: 3),
                    Text(
                      '${durationLabel(video.durationSeconds)} · $ownStatus',
                    ),
                    if (partnerStatus != null)
                      Text(
                        partnerStatus,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                  ],
                ),
              ),
              Text(
                video.me.liked ? '♥' : '→',
                style: TextStyle(
                  fontSize: 22,
                  color: video.me.liked
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
