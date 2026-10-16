class ProgressSummary {
  const ProgressSummary({required this.percent, required this.completedVideos});

  factory ProgressSummary.fromJson(Map<String, dynamic> json) =>
      ProgressSummary(
        percent: (json['percent'] as num).toInt(),
        completedVideos: (json['completedVideos'] as num).toInt(),
      );

  final int percent;
  final int completedVideos;
}

class MeSummary extends ProgressSummary {
  const MeSummary({
    required super.percent,
    required super.completedVideos,
    required this.likedVideos,
  });

  factory MeSummary.fromJson(Map<String, dynamic> json) => MeSummary(
    percent: (json['percent'] as num).toInt(),
    completedVideos: (json['completedVideos'] as num).toInt(),
    likedVideos: (json['likedVideos'] as num).toInt(),
  );

  final int likedVideos;
}

class PartnerSummary extends ProgressSummary {
  const PartnerSummary({
    required this.role,
    required super.percent,
    required super.completedVideos,
    required this.isCurrentlyWatching,
  });

  factory PartnerSummary.fromJson(Map<String, dynamic> json) => PartnerSummary(
    role: json['role'] as String,
    percent: (json['percent'] as num).toInt(),
    completedVideos: (json['completedVideos'] as num).toInt(),
    isCurrentlyWatching: json['isCurrentlyWatching'] as bool,
  );

  final String role;
  final bool isCurrentlyWatching;
}

class MasterclassCardModel {
  const MasterclassCardModel({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoCount,
    required this.totalDurationSeconds,
    required this.me,
    this.partner,
  });

  factory MasterclassCardModel.fromJson(Map<String, dynamic> json) =>
      MasterclassCardModel(
        id: json['id'] as String,
        slug: json['slug'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        thumbnailUrl: json['thumbnailUrl'] as String,
        videoCount: (json['videoCount'] as num).toInt(),
        totalDurationSeconds: (json['totalDurationSeconds'] as num).toInt(),
        me: MeSummary.fromJson(json['me'] as Map<String, dynamic>),
        partner: json['partner'] == null
            ? null
            : PartnerSummary.fromJson(json['partner'] as Map<String, dynamic>),
      );

  final String id;
  final String slug;
  final String title;
  final String description;
  final String thumbnailUrl;
  final int videoCount;
  final int totalDurationSeconds;
  final MeSummary me;
  final PartnerSummary? partner;
}

class VideoActivity {
  const VideoActivity({
    required this.liked,
    required this.furthestSeconds,
    required this.percent,
    required this.completed,
  });

  factory VideoActivity.fromJson(Map<String, dynamic> json) => VideoActivity(
    liked: json['liked'] as bool,
    furthestSeconds: (json['furthestSeconds'] as num).toInt(),
    percent: (json['percent'] as num).toInt(),
    completed: json['completed'] as bool,
  );

  final bool liked;
  final int furthestSeconds;
  final int percent;
  final bool completed;
}

class PartnerActivity extends VideoActivity {
  const PartnerActivity({
    required this.role,
    required super.liked,
    required super.furthestSeconds,
    required super.percent,
    required super.completed,
    required this.isCurrentlyWatching,
  });

  factory PartnerActivity.fromJson(Map<String, dynamic> json) =>
      PartnerActivity(
        role: json['role'] as String,
        liked: json['liked'] as bool,
        furthestSeconds: (json['furthestSeconds'] as num).toInt(),
        percent: (json['percent'] as num).toInt(),
        completed: json['completed'] as bool,
        isCurrentlyWatching: json['isCurrentlyWatching'] as bool,
      );

  final String role;
  final bool isCurrentlyWatching;
}

class VideoModel {
  const VideoModel({
    required this.id,
    required this.masterclassId,
    required this.title,
    required this.description,
    required this.mediaUrl,
    required this.thumbnailUrl,
    required this.durationSeconds,
    required this.sortOrder,
    required this.me,
    this.partner,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) => VideoModel(
    id: json['id'] as String,
    masterclassId: json['masterclassId'] as String? ?? '',
    title: json['title'] as String,
    description: json['description'] as String,
    mediaUrl: json['mediaUrl'] as String,
    thumbnailUrl: json['thumbnailUrl'] as String,
    durationSeconds: (json['durationSeconds'] as num).toInt(),
    sortOrder: (json['sortOrder'] as num).toInt(),
    me: VideoActivity.fromJson(json['me'] as Map<String, dynamic>),
    partner: json['partner'] == null
        ? null
        : PartnerActivity.fromJson(json['partner'] as Map<String, dynamic>),
  );

  final String id;
  final String masterclassId;
  final String title;
  final String description;
  final String mediaUrl;
  final String thumbnailUrl;
  final int durationSeconds;
  final int sortOrder;
  final VideoActivity me;
  final PartnerActivity? partner;
}

class MasterclassDetailModel {
  const MasterclassDetailModel({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.me,
    required this.videos,
    this.partner,
  });

  factory MasterclassDetailModel.fromJson(Map<String, dynamic> json) =>
      MasterclassDetailModel(
        id: json['id'] as String,
        slug: json['slug'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        thumbnailUrl: json['thumbnailUrl'] as String,
        me: ProgressSummary.fromJson(json['me'] as Map<String, dynamic>),
        partner: json['partner'] == null
            ? null
            : PartnerSummary.fromJson(json['partner'] as Map<String, dynamic>),
        videos: (json['videos'] as List<dynamic>)
            .map((item) => VideoModel.fromJson(item as Map<String, dynamic>))
            .toList(growable: false),
      );

  final String id;
  final String slug;
  final String title;
  final String description;
  final String thumbnailUrl;
  final ProgressSummary me;
  final PartnerSummary? partner;
  final List<VideoModel> videos;
}

class ProgressResult {
  const ProgressResult({
    required this.furthestSeconds,
    required this.durationSeconds,
    required this.percent,
    required this.completed,
  });

  factory ProgressResult.fromJson(Map<String, dynamic> json) => ProgressResult(
    furthestSeconds: (json['furthestSeconds'] as num).toInt(),
    durationSeconds: (json['durationSeconds'] as num).toInt(),
    percent: (json['percent'] as num).toInt(),
    completed: json['completed'] as bool,
  );

  final int furthestSeconds;
  final int durationSeconds;
  final int percent;
  final bool completed;
}
