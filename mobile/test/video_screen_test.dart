import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sitaara/core/models/api_models.dart';
import 'package:sitaara/core/providers.dart';
import 'package:sitaara/core/theme/app_theme.dart';
import 'package:sitaara/features/content/application/content_providers.dart';
import 'package:sitaara/features/content/data/content_models.dart';
import 'package:sitaara/features/content/data/content_repository.dart';
import 'package:sitaara/features/content/presentation/video_screen.dart';

void main() {
  testWidgets(
    'media failure keeps activity usable and failed like rolls back',
    (tester) async {
      final likeResult = Completer<bool>();
      final repository = _ContentRepositoryStub(likeResult.future);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            videoProvider.overrideWith((ref, id) async => _video),
            contentRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: VideoScreen(
              videoId: 'video-1',
              playerBuilder: (context, video, onPosition) => const AspectRatio(
                aspectRatio: 16 / 9,
                child: ColoredBox(
                  color: Colors.black,
                  child: Center(child: Text('Retry video')),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Retry video'), findsOneWidget);
      expect(find.text('Like this lesson'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Dad has not started this lesson.'),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Dad has not started this lesson.'), findsOneWidget);

      await tester.ensureVisible(find.text('Like this lesson'));
      await tester.tap(find.text('Like this lesson'));
      await tester.pump();
      expect(find.text('Liked'), findsOneWidget);

      likeResult.completeError(
        const ApiException(code: 'OFFLINE', message: 'Could not update like.'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Like this lesson'), findsOneWidget);
      expect(find.text('Could not update like.'), findsOneWidget);
    },
  );
}

const _video = VideoModel(
  id: 'video-1',
  masterclassId: 'masterclass-1',
  title: 'Pause before reacting',
  description: 'A short practical lesson.',
  mediaUrl: 'https://invalid.example.test/video.mp4',
  thumbnailUrl: 'https://invalid.example.test/poster.jpg',
  durationSeconds: 100,
  sortOrder: 1,
  me: VideoActivity(
    liked: false,
    furthestSeconds: 0,
    percent: 0,
    completed: false,
  ),
  partner: PartnerActivity(
    role: 'dad',
    liked: false,
    furthestSeconds: 0,
    percent: 0,
    completed: false,
    isCurrentlyWatching: false,
  ),
);

class _ContentRepositoryStub implements ContentRepository {
  const _ContentRepositoryStub(this.likeResult);

  final Future<bool> likeResult;

  @override
  Future<bool> setLiked(String id, {required bool liked}) => likeResult;

  @override
  Future<MasterclassDetailModel> getMasterclass(
    String id, {
    CancelToken? cancelToken,
  }) => throw UnimplementedError();

  @override
  Future<VideoModel> getVideo(String id, {CancelToken? cancelToken}) =>
      throw UnimplementedError();

  @override
  Future<List<MasterclassCardModel>> listMasterclasses({
    CancelToken? cancelToken,
  }) => throw UnimplementedError();

  @override
  Future<ProgressResult> updateProgress(String id, int seconds) =>
      throw UnimplementedError();
}
