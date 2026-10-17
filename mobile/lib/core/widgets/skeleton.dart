import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SitaaraSkeleton extends StatefulWidget {
  const SitaaraSkeleton({
    super.key,
    required this.child,
    this.semanticLabel = 'Loading content',
  });

  final Widget child;
  final String semanticLabel;

  @override
  State<SitaaraSkeleton> createState() => _SitaaraSkeletonState();
}

class _SitaaraSkeletonState extends State<SitaaraSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: widget.semanticLabel,
    child: ExcludeSemantics(
      child: FadeTransition(
        opacity: Tween(begin: .45, end: .9).animate(_controller),
        child: widget.child,
      ),
    ),
  );
}

class SkeletonBlock extends StatelessWidget {
  const SkeletonBlock({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = 18,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: AppColors.lavender,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

class ContentListSkeleton extends StatelessWidget {
  const ContentListSkeleton({super.key});

  @override
  Widget build(BuildContext context) => SitaaraSkeleton(
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        SkeletonBlock(width: 190, height: 30),
        SizedBox(height: 10),
        SkeletonBlock(width: 120, height: 18),
        SizedBox(height: 28),
        SkeletonBlock(height: 104, radius: 28),
        SizedBox(height: 26),
        SkeletonBlock(width: 140, height: 24),
        SizedBox(height: 14),
        SkeletonBlock(height: 250, radius: 28),
        SizedBox(height: 18),
        SkeletonBlock(height: 250, radius: 28),
      ],
    ),
  );
}
