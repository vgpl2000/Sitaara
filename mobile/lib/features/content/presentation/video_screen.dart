import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/api_models.dart';
import '../../../core/providers.dart';
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
      appBar: AppBar(title: const Text('Lesson')),
      body: SafeArea(
        child: video.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => ContentError(
            error: error,
            onRetry: () => ref.invalidate(videoProvider(videoId)),
          ),
          data: (item) =>
              _VideoExperience(video: item, playerBuilder: playerBuilder),
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
  bool _savingLike = false;
  late final ProgressReporter _progressReporter;

  @override
  void initState() {
    super.initState();
    _liked = widget.video.me.liked;
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

  Future<void> _toggleLike() async {
    if (_savingLike) return;
    final previous = _liked;
    setState(() {
      _liked = !previous;
      _savingLike = true;
    });
    try {
      final saved = await ref
          .read(contentRepositoryProvider)
          .setLiked(widget.video.id, liked: _liked);
      if (mounted) setState(() => _liked = saved);
      ref.invalidate(videoProvider(widget.video.id));
      if (widget.video.masterclassId.isNotEmpty) {
        ref.invalidate(masterclassProvider(widget.video.masterclassId));
      }
      ref.invalidate(masterclassesProvider);
    } catch (error) {
      if (!mounted) return;
      setState(() => _liked = previous);
      final message = error is ApiException
          ? error.message
          : 'Could not update like.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _savingLike = false);
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
      OutlinedButton.icon(
        onPressed: _savingLike ? null : _toggleLike,
        icon: Icon(_liked ? Icons.favorite : Icons.favorite_border),
        label: Text(_liked ? 'Liked' : 'Like this lesson'),
      ),
      const SizedBox(height: 14),
      _ActivityCard(video: widget.video),
      if (widget.video.masterclassId.isNotEmpty) ...[
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () =>
              context.go('/masterclasses/${widget.video.masterclassId}'),
          icon: const Icon(Icons.arrow_back),
          label: const Text('Back to masterclass'),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your progress · ${video.me.percent}%'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: video.me.percent / 100,
              minHeight: 8,
            ),
            const SizedBox(height: 14),
            Text(
              partner == null
                  ? 'Invite your partner to learn together.'
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
