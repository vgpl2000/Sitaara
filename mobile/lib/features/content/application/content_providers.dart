import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/content_models.dart';

final masterclassesProvider =
    FutureProvider.autoDispose<List<MasterclassCardModel>>((ref) {
      final cancellation = CancelToken();
      ref.onDispose(() => cancellation.cancel('Library left'));
      return ref
          .read(contentRepositoryProvider)
          .listMasterclasses(cancelToken: cancellation);
    });

final masterclassProvider = FutureProvider.autoDispose
    .family<MasterclassDetailModel, String>((ref, id) {
      return ref.read(contentRepositoryProvider).getMasterclass(id);
    });

final videoProvider = FutureProvider.autoDispose.family<VideoModel, String>((
  ref,
  id,
) {
  return ref.read(contentRepositoryProvider).getVideo(id);
});
