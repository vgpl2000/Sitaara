import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/api_models.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/skeleton.dart';
import '../application/progress_reporter.dart';
import '../application/content_providers.dart';
import '../data/content_models.dart';
import 'content_widgets.dart';
import 'sitaara_video_player.dart';

typedef LessonPlayerBuilder = Widget Function(
  BuildContext context,
  VideoModel video,
  PlaybackPositionCallback onPosition,
);

class VideoScreen extends ConsumerWidget {
  const VideoScreen({super.key, required this.videoId, this.playerBuilder});

  final String videoId;
  final LessonPlayerBuilder? playerBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final video = ref.watch(videoProvider(videoId));
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 82,
        leading: TextButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/library'),
          child: const Text('← Back'),
        ),
        title: const Text('Lesson'),
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
          child: video.when(
            loading: () => const ContentListSkeleton(),
            error: (error, stack) => ContentError(
              error: error,
              onRetry: () => ref.invalidate(videoProvider(videoId)),
            ),
            data: (item) =>
                _VideoExperience(video: item, playerBuilder: playerBuilder),
          ),
        ),
      ),
    );
  }
}

class _VideoExperience extends ConsumerStatefulWidget {
  const _VideoExperience({required this.video, this.playerBuilder});

  final VideoModel video;
  final LessonPlayerBuilder? playerBuilder;

  @override
  ConsumerState<_VideoExperience> createState() => _VideoExperienceState();
}

class _VideoExperienceState extends ConsumerState<_VideoExperience> {
  bool _liked = false;
  bool _confirmedLiked = false;
  bool _likeSyncRunning = false;
  late final ProgressReporter _progressReporter;

  @override
  void initState() {
    super.initState();
    _liked = widget.video.me.liked;
    _confirmedLiked = _liked;
    _progressReporter = ProgressReporter(
      initialSeconds: widget.video.me.furthestSeconds,
      submit: (seconds) => ref
          .read(contentRepositoryProvider)
          .updateProgress(widget.video.id, seconds),
    );
  }

  Future<void> _flushProgress(int seconds) async {
    try {
      await _progressReporter.report(seconds);
    } catch (_) {
      // Best-effort lifecycle updates are retried by the next playback tick.
    }
  }

  void _toggleLike() {
    setState(() => _liked = !_liked);
    unawaited(_syncLike());
  }

  Future<void> _syncLike() async {
    if (_likeSyncRunning) return;
    _likeSyncRunning = true;
    try {
      while (mounted && _confirmedLiked != _liked) {
        final requested = _liked;
        try {
          final saved = await ref
              .read(contentRepositoryProvider)
              .setLiked(widget.video.id, liked: requested);
          _confirmedLiked = saved;
          if (mounted && _liked == requested && _liked != saved) {
            setState(() => _liked = saved);
          }
          ref.invalidate(videoProvider(widget.video.id));
          if (widget.video.masterclassId.isNotEmpty) {
            ref.invalidate(masterclassProvider(widget.video.masterclassId));
          }
          ref.invalidate(masterclassesProvider);
        } catch (error) {
          if (!mounted) return;
          setState(() => _liked = _confirmedLiked);
          final message = error is ApiException
              ? error.message
              : 'Could not update your like.';
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message)));
          return;
        }
      }
    } finally {
      _likeSyncRunning = false;
      if (mounted && _confirmedLiked != _liked) unawaited(_syncLike());
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
    children: [
      _player(context),
      const SizedBox(height: 22),
      Text(
        widget.video.title,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 8),
      Text(widget.video.description),
      const SizedBox(height: 14),
      Align(
        alignment: Alignment.centerLeft,
        child: _AnimatedLikeButton(liked: _liked, onPressed: _toggleLike),
      ),
      const SizedBox(height: 14),
      _ActivityCard(video: widget.video),
      if (widget.video.masterclassId.isNotEmpty) ...[
        const SizedBox(height: 12),
        TextButton(
          onPressed: () =>
              context.go('/masterclasses/${widget.video.masterclassId}'),
          child: const Text('← Back to this masterclass'),
        ),
      ],
    ],
  );

  Widget _player(BuildContext context) {
    final builder = widget.playerBuilder;
    if (builder != null) {
      return builder(context, widget.video, _flushProgress);
    }
    return SitaaraVideoPlayer(
      mediaUrl: widget.video.mediaUrl,
      thumbnailUrl: widget.video.thumbnailUrl,
      initialPositionSeconds: widget.video.me.furthestSeconds,
      onPosition: _flushProgress,
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.video});

  final VideoModel video;

  @override
  Widget build(BuildContext context) {
    final partner = video.partner;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your learning story',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text('You’re ${video.me.percent}% through this lesson.'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: video.me.percent / 100,
              minHeight: 8,
            ),
            const SizedBox(height: 14),
            Text(
              partner == null
                  ? 'Invite your partner so this can become a shared journey.'
                  : partner.completed
                  ? 'Completed by ${roleLabel(partner.role)}${partner.liked ? ' · Liked' : ''}'
                  : partner.percent > 0
                  ? '${roleLabel(partner.role)} watched ${partner.percent}%${partner.liked ? ' · Liked' : ''}'
                  : '${roleLabel(partner.role)} has not started this lesson.',
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedLikeButton extends StatefulWidget {
  const _AnimatedLikeButton({required this.liked, required this.onPressed});

  final bool liked;
  final VoidCallback onPressed;

  @override
  State<_AnimatedLikeButton> createState() => _AnimatedLikeButtonState();
}

class _AnimatedLikeButtonState extends State<_AnimatedLikeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
  }

  @override
  void didUpdateWidget(covariant _AnimatedLikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.liked != oldWidget.liked &&
        !MediaQuery.disableAnimationsOf(context)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    toggled: widget.liked,
    label: widget.liked ? 'Unlike this lesson' : 'Like this lesson',
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: widget.liked ? AppColors.primary : AppColors.primarySoft,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(99),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final pulse =
                        1 + (0.28 * (1 - (_controller.value * 2 - 1).abs()));
                    return Transform.scale(scale: pulse, child: child);
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Text(
                      widget.liked ? '♥' : '♡',
                      key: ValueKey(widget.liked),
                      style: TextStyle(
                        fontSize: 23,
                        color: widget.liked
                            ? AppColors.yellow
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      axis: Axis.horizontal,
                      child: child,
                    ),
                  ),
                  child: Text(
                    widget.liked ? 'Liked' : 'Like',
                    key: ValueKey(widget.liked),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: widget.liked ? Colors.white : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
