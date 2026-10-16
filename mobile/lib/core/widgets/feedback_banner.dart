import 'package:flutter/material.dart';

import '../models/api_models.dart';
import '../theme/app_colors.dart';

class FeedbackBanner extends StatelessWidget {
  const FeedbackBanner({super.key, required this.message, this.requestId});

  factory FeedbackBanner.fromException(ApiException error) =>
      FeedbackBanner(message: error.message, requestId: error.requestId);

  final String message;
  final String? requestId;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.errorSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              requestId == null ? message : '$message\nRequest ID: $requestId',
              style: const TextStyle(color: AppColors.error, height: 1.4),
            ),
          ),
        ],
      ),
    ),
  );
}
