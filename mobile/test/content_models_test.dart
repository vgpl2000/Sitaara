import 'package:flutter_test/flutter_test.dart';
import 'package:sitaara/features/content/data/content_models.dart';

void main() {
  test('masterclass card parses own and partner progress', () {
    final card = MasterclassCardModel.fromJson({
      'id': 'masterclass-1',
      'slug': 'everyday-parenting',
      'title': 'Everyday Parenting',
      'description': 'Practical lessons.',
      'thumbnailUrl': 'https://example.test/poster.jpg',
      'videoCount': 5,
      'totalDurationSeconds': 900,
      'me': {'percent': 40, 'completedVideos': 2, 'likedVideos': 1},
      'partner': {
        'role': 'dad',
        'percent': 60,
        'completedVideos': 3,
        'isCurrentlyWatching': true,
      },
    });

    expect(card.videoCount, 5);
    expect(card.me.percent, 40);
    expect(card.me.likedVideos, 1);
    expect(card.partner?.role, 'dad');
    expect(card.partner?.isCurrentlyWatching, isTrue);
  });

  test('video parses an unlinked partner without inventing activity', () {
    final video = VideoModel.fromJson({
      'id': 'video-1',
      'masterclassId': 'masterclass-1',
      'title': 'Pause before reacting',
      'description': 'A short lesson.',
      'mediaUrl': 'https://example.test/video.mp4',
      'thumbnailUrl': 'https://example.test/poster.jpg',
      'durationSeconds': 120,
      'sortOrder': 1,
      'me': {
        'liked': false,
        'furthestSeconds': 0,
        'percent': 0,
        'completed': false,
      },
      'partner': null,
    });

    expect(video.partner, isNull);
    expect(video.me.completed, isFalse);
    expect(video.durationSeconds, 120);
  });
}
