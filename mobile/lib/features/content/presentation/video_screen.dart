import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../core/models/api_models.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../application/content_providers.dart';
import '../data/content_models.dart';
import 'content_widgets.dart';

class VideoScreen extends ConsumerWidget {
  const VideoScreen({super.key, required this.videoId});

  final String videoId;

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
          data: (item) => _VideoExperience(video: item),
        ),
      ),
    );
  }
}

class _VideoExperience extends ConsumerStatefulWidget {
  const _VideoExperience({required this.video});

  final VideoModel video;

  @override
  ConsumerState<_VideoExperience> createState() => _VideoExperienceState();
}

class _VideoExperienceState extends ConsumerState<_VideoExperience>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  Timer? _reportTimer;
  Object? _playbackError;
  bool _liked = false;
  bool _savingLike = false;
  bool _completionFlushed = false;
  int _lastReported = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _liked = widget.video.me.liked;
    _lastReported = widget.video.me.furthestSeconds;
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.video.mediaUrl),
    );
    try {
      await controller.initialize();
      if (widget.video.me.furthestSeconds > 0 &&
          widget.video.me.furthestSeconds < widget.video.durationSeconds) {
        await controller.seekTo(
          Duration(seconds: widget.video.me.furthestSeconds),
        );
      }
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _playbackError = null;
      });
      controller.addListener(_handlePlaybackChange);
      _reportTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (controller.value.isPlaying) unawaited(_flushProgress());
      });
    } catch (error) {
      await controller.dispose();
      if (mounted) setState(() => _playbackError = error);
    }
  }

  void _handlePlaybackChange() {
    final value = _controller?.value;
    if (value == null || !mounted) return;
    if (value.hasError && _playbackError == null) {
      setState(
        () => _playbackError = value.errorDescription ?? 'Playback failed.',
      );
      return;
    }
    final reachedEnd =
        value.duration > Duration.zero &&
        value.position >= value.duration - const Duration(seconds: 1);
    if (reachedEnd && !_completionFlushed) {
      _completionFlushed = true;
      unawaited(_flushProgress());
    }
  }

  Future<void> _flushProgress() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final seconds = controller.value.position.inSeconds;
    if (seconds <= _lastReported) return;
    try {
      final result = await ref
          .read(contentRepositoryProvider)
          .updateProgress(widget.video.id, seconds);
      _lastReported = result.furthestSeconds;
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      unawaited(_flushProgress());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reportTimer?.cancel();
    unawaited(_flushProgress());
    unawaited(_controller?.dispose());
    super.dispose();
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
    final controller = _controller;
    if (_playbackError != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: ColoredBox(
          color: AppColors.textPrimary,
          child: Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() => _playbackError = null);
                unawaited(_initialize());
              },
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Retry video',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      );
    }
    if (controller == null) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: ColoredBox(
          color: AppColors.textPrimary,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return AspectRatio(
      aspectRatio: controller.value.aspectRatio == 0
          ? 16 / 9
          : controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(controller),
          ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: controller,
            builder: (context, value, child) => IconButton.filled(
              tooltip: value.isPlaying ? 'Pause' : 'Play',
              iconSize: 34,
              onPressed: () async {
                if (value.isPlaying) {
                  await controller.pause();
                  await _flushProgress();
                } else {
                  await controller.play();
                }
              },
              icon: Icon(value.isPlaying ? Icons.pause : Icons.play_arrow),
            ),
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 2,
            child: VideoProgressIndicator(
              controller,
              allowScrubbing: true,
              colors: const VideoProgressColors(playedColor: AppColors.green),
            ),
          ),
        ],
      ),
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
