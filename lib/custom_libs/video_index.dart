import 'dart:convert';

import 'package:flutter/services.dart';

typedef VideoIndexAssetLoader = Future<String> Function(String path);

class VideoIndex {
  static const assetPath = 'assets/questions/videos.json';
  static Map<String, String> _questionUrls = const {};

  static Future<void> load({VideoIndexAssetLoader? loadAsset}) async {
    final loader = loadAsset ?? rootBundle.loadString;
    final data = jsonDecode(await loader(assetPath)) as Map;
    final urls = data['question_urls'] as Map? ?? const {};
    _questionUrls = urls.map(
      (questionId, url) => MapEntry(questionId.toString(), url.toString()),
    );
  }

  static bool hasVideo(String questionId) =>
      _questionUrls.containsKey(questionId);

  static String? urlFor(String questionId) => _questionUrls[questionId];
}
