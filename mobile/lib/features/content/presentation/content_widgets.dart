import 'package:flutter/material.dart';

import '../../../core/models/api_models.dart';
import '../../../core/theme/app_colors.dart';

class NetworkArtwork extends StatelessWidget {
  const NetworkArtwork({
    super.key,
    required this.url,
    this.height = 176,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
  });

  final String url;
  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: borderRadius,
    child: Image.network(
      url,
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        color: AppColors.primarySoft,
        alignment: Alignment.center,
        child: const Icon(
          Icons.play_circle_outline,
          size: 44,
          color: AppColors.primary,
        ),
      ),
    ),
  );
}

class ContentError extends StatelessWidget {
  const ContentError({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final message = error is ApiException
        ? (error as ApiException).message
        : 'We could not load this right now.';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 42),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

String roleLabel(String role) => role == 'mom' ? 'Mom' : 'Dad';

String childAgeLabel(DateTime dateOfBirth) {
  final today = DateTime.now();
  var months =
      (today.year - dateOfBirth.year) * 12 + today.month - dateOfBirth.month;
  if (today.day < dateOfBirth.day) months--;
  if (months < 12) return '${months.clamp(0, 11)} months';
  final years = months ~/ 12;
  return '$years ${years == 1 ? 'year' : 'years'}';
}

String durationLabel(int seconds) {
  final minutes = (seconds / 60).ceil();
  if (minutes < 60) return '$minutes min';
  final hours = minutes ~/ 60;
  final remainder = minutes % 60;
  return remainder == 0 ? '$hours hr' : '$hours hr $remainder min';
}
