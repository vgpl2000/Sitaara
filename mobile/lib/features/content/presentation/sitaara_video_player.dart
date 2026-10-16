import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_colors.dart';

typedef PlaybackPositionCallback = Future<void> Function(int seconds);

/// Reusable Sitaara lesson player with lifecycle-safe progress reporting.
class SitaaraVideoPlayer extends StatefulWidget {
  const SitaaraVideoPlayer({
    super.key,
    required this.mediaUrl,
    required this.thumbnailUrl,
    required this.initialPositionSeconds,
    required this.onPosition,
  });

  final String mediaUrl;
  final String thumbnailUrl;
  final int initialPositionSeconds;
  final PlaybackPositionCallback onPosition;

  @override
  State<SitaaraVideoPlayer> createState() => _SitaaraVideoPlayerState();
}

class _SitaaraVideoPlayerState extends State<SitaaraVideoPlayer>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  Timer? _reportTimer;
  Object? _error;
  bool _completionReported = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    _reportTimer?.cancel();
    final previous = _controller;
    _controller = null;
    if (previous != null) {
      previous.removeListener(_listen);
      await previous.dispose();
    }
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.mediaUrl),
    );
    try {
      await controller.initialize();
      final initial = widget.initialPositionSeconds;
      if (initial > 0 && initial < controller.value.duration.inSeconds) {
        await controller.seekTo(Duration(seconds: initial));
      }
      if (!mounted) {
        await controller.dispose();
        return;
      }
      controller.addListener(_listen);
      setState(() {
        _controller = controller;
        _error = null;
        _completionReported = false;
      });
      _reportTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (controller.value.isPlaying) unawaited(_report());
      });
    } catch (error) {
      await controller.dispose();
      if (mounted) setState(() => _error = error);
    }
  }

  void _listen() {
    final value = _controller?.value;
    if (value == null || !mounted) return;
    if (value.hasError && _error == null) {
      setState(() => _error = value.errorDescription ?? 'Playback failed.');
      return;
    }
    final ended =
        value.duration > Duration.zero &&
        value.position >= value.duration - const Duration(seconds: 1);
    if (ended && !_completionReported) {
      _completionReported = true;
      unawaited(_report());
    }
  }

  Future<void> _report() async {
    final value = _controller?.value;
    if (value == null || !value.isInitialized) return;
    await widget.onPosition(value.position.inSeconds);
  }

  Future<void> _togglePlayback() async {
    final controller = _controller;
    if (controller == null) return;
    final value = controller.value;
    if (value.position >= value.duration - const Duration(seconds: 1)) {
      _completionReported = false;
      await controller.seekTo(Duration.zero);
    }
    if (controller.value.isPlaying) {
      await controller.pause();
      await _report();
    } else {
      await controller.play();
    }
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_report());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reportTimer?.cancel();
    final controller = _controller;
    if (controller != null) {
      controller.removeListener(_listen);
      unawaited(_report());
      unawaited(controller.dispose());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_error != null) {
      return _PlayerFrame(
        child: Semantics(
          label: 'Video unavailable',
          child: Center(
            child: FilledButton.tonalIcon(
              onPressed: () {
                setState(() => _error = null);
                unawaited(_initialize());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry video'),
            ),
          ),
        ),
      );
    }
    if (controller == null) {
      return _PlayerFrame(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
            const ColoredBox(color: Color(0x88000000)),
            const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                semanticsLabel: 'Loading video',
              ),
            ),
          ],
        ),
      );
    }

    return AspectRatio(
      aspectRatio: controller.value.aspectRatio == 0
          ? 16 / 9
          : controller.value.aspectRatio,
      child: ColoredBox(
        color: AppColors.textPrimary,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(controller),
            ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: controller,
              builder: (context, value, child) => Stack(
                alignment: Alignment.center,
                children: [
                  if (value.isBuffering)
                    const CircularProgressIndicator(
                      color: Colors.white,
                      semanticsLabel: 'Buffering video',
                    ),
                  IconButton.filled(
                    tooltip: value.isPlaying ? 'Pause video' : 'Play video',
                    iconSize: 34,
                    onPressed: _togglePlayback,
                    icon: Icon(
                      value.isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 2,
              child: Semantics(
                label: 'Video progress. Drag to seek.',
                child: VideoProgressIndicator(
                  controller,
                  allowScrubbing: true,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  colors: const VideoProgressColors(
                    playedColor: AppColors.green,
                    bufferedColor: Color(0x99FFFFFF),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerFrame extends StatelessWidget {
  const _PlayerFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 16 / 9,
    child: ColoredBox(color: AppColors.textPrimary, child: child),
  );
}
