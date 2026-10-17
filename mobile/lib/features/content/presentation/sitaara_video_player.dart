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
  Timer? _controlsTimer;
  Object? _error;
  bool _completionReported = false;
  bool _controlsVisible = true;

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
      _showControls(autoHide: false);
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
      _showControls(autoHide: false);
    } else {
      await controller.play();
      _showControls();
    }
    if (mounted) setState(() {});
  }

  void _showControls({bool autoHide = true}) {
    _controlsTimer?.cancel();
    if (mounted && !_controlsVisible) setState(() => _controlsVisible = true);
    if (autoHide && (_controller?.value.isPlaying ?? false)) {
      _controlsTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && (_controller?.value.isPlaying ?? false)) {
          setState(() => _controlsVisible = false);
        }
      });
    }
  }

  void _toggleControls() {
    if (_controlsVisible) {
      _controlsTimer?.cancel();
      setState(() => _controlsVisible = false);
    } else {
      _showControls();
    }
  }

  Future<void> _showFullscreen() async {
    final controller = _controller;
    if (controller == null || !mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => _FullscreenPlayer(
          controller: controller,
          onTogglePlayback: _togglePlayback,
        ),
      ),
    );
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
    _controlsTimer?.cancel();
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
            Center(
              child: Semantics(
                label: 'Loading video',
                child: const CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return _VideoViewport(
      aspectRatio: controller.value.aspectRatio == 0
          ? 16 / 9
          : controller.value.aspectRatio,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleControls,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(controller),
            Positioned.fill(
              child: ValueListenableBuilder<VideoPlayerValue>(
                valueListenable: controller,
                builder: (context, value, child) => Stack(
                  alignment: Alignment.center,
                  children: [
                    if (value.isBuffering)
                      const CircularProgressIndicator(color: Colors.white),
                    Positioned.fill(
                      child: AnimatedOpacity(
                        opacity: _controlsVisible ? 1 : 0,
                        duration: const Duration(milliseconds: 220),
                        child: IgnorePointer(
                          ignoring: !_controlsVisible,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              IconButton.filled(
                                tooltip: value.isPlaying
                                    ? 'Pause video'
                                    : 'Play video',
                                iconSize: 34,
                                onPressed: _togglePlayback,
                                icon: Icon(
                                  value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
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
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    colors: const VideoProgressColors(
                                      playedColor: AppColors.green,
                                      bufferedColor: Color(0x99FFFFFF),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton.filledTonal(
                                  tooltip: 'View video full screen',
                                  onPressed: _showFullscreen,
                                  icon: const Icon(Icons.fullscreen),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
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
  Widget build(BuildContext context) =>
      _VideoViewport(aspectRatio: 16 / 9, child: child);
}

class _VideoViewport extends StatelessWidget {
  const _VideoViewport({required this.aspectRatio, required this.child});

  final double aspectRatio;
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const maxHeight = 460.0;
      final naturalHeight = constraints.maxWidth / aspectRatio;
      final height = naturalHeight.clamp(190.0, maxHeight);
      final width = (height * aspectRatio).clamp(0.0, constraints.maxWidth);
      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            width: width,
            height: height,
            child: ColoredBox(color: AppColors.textPrimary, child: child),
          ),
        ),
      );
    },
  );
}

class _FullscreenPlayer extends StatefulWidget {
  const _FullscreenPlayer({
    required this.controller,
    required this.onTogglePlayback,
  });

  final VideoPlayerController controller;
  final Future<void> Function() onTogglePlayback;

  @override
  State<_FullscreenPlayer> createState() => _FullscreenPlayerState();
}

class _FullscreenPlayerState extends State<_FullscreenPlayer> {
  Timer? _controlsTimer;
  bool _controlsVisible = true;
  bool _closingAtEnd = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listen);
    WidgetsBinding.instance.addPostFrameCallback((_) => _showControls());
  }

  void _listen() {
    final value = widget.controller.value;
    final ended =
        value.duration > Duration.zero &&
        value.position >= value.duration - const Duration(seconds: 1);
    if (!ended || _closingAtEnd || !mounted) return;
    _closingAtEnd = true;
    _controlsTimer?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  void _showControls({bool autoHide = true}) {
    _controlsTimer?.cancel();
    if (mounted && !_controlsVisible) setState(() => _controlsVisible = true);
    if (autoHide && widget.controller.value.isPlaying) {
      _controlsTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && widget.controller.value.isPlaying) {
          setState(() => _controlsVisible = false);
        }
      });
    }
  }

  void _toggleControls() {
    if (_controlsVisible) {
      _controlsTimer?.cancel();
      setState(() => _controlsVisible = false);
    } else {
      _showControls();
    }
  }

  Future<void> _togglePlayback() async {
    await widget.onTogglePlayback();
    if (!mounted) return;
    _showControls(autoHide: widget.controller.value.isPlaying);
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    widget.controller.removeListener(_listen);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleControls,
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: widget.controller.value.aspectRatio == 0
                    ? 16 / 9
                    : widget.controller.value.aspectRatio,
                child: VideoPlayer(widget.controller),
              ),
            ),
            Positioned.fill(
              child: ValueListenableBuilder<VideoPlayerValue>(
                valueListenable: widget.controller,
                builder: (context, value, child) => Stack(
                  children: [
                    if (value.isBuffering)
                      const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    Positioned.fill(
                      child: AnimatedOpacity(
                        opacity: _controlsVisible ? 1 : 0,
                        duration: const Duration(milliseconds: 220),
                        child: IgnorePointer(
                          ignoring: !_controlsVisible,
                          child: Stack(
                            children: [
                              Center(
                                child: IconButton.filled(
                                  tooltip: value.isPlaying
                                      ? 'Pause video'
                                      : 'Play video',
                                  iconSize: 38,
                                  onPressed: _togglePlayback,
                                  icon: Icon(
                                    value.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 16,
                                right: 16,
                                bottom: 16,
                                child: VideoProgressIndicator(
                                  widget.controller,
                                  allowScrubbing: true,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  colors: const VideoProgressColors(
                                    playedColor: AppColors.green,
                                    bufferedColor: Color(0x99FFFFFF),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Semantics(
                                  button: true,
                                  label: 'Close full screen video',
                                  child: Material(
                                    color: Colors.white,
                                    shape: const StadiumBorder(),
                                    elevation: 2,
                                    child: InkWell(
                                      customBorder: const StadiumBorder(),
                                      onTap: () => Navigator.of(context).pop(),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 18,
                                          vertical: 12,
                                        ),
                                        child: Text(
                                          '← Close',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
