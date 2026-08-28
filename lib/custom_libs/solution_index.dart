import 'dart:convert';

import 'package:flutter/services.dart';

typedef SolutionIndexAssetLoader = Future<String> Function(String path);

class SolutionIndex {
  static const assetPath = 'assets/questions/solutions.json';
  static Set<String> _questionIds = const {};

  static Future<void> load({SolutionIndexAssetLoader? loadAsset}) async {
    final loader = loadAsset ?? rootBundle.loadString;
    final data = jsonDecode(await loader(assetPath)) as Map;
    final ids = data['question_ids'] as List? ?? const [];
    _questionIds = ids.map((id) => id.toString()).toSet();
  }

  static bool hasSolution(String questionId) =>
      _questionIds.contains(questionId);

  static String urlFor(String questionId) =>
      Uri.https('50ohm.de', '/$questionId.html').toString();
}
