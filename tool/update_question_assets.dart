import 'dart:convert';
import 'dart:io';

const _editions = ['N', 'E', 'NE', 'A', 'EA', 'NEA'];
const _defaultQuestionIndexUrl = 'https://50ohm.de/assets/question_index.json';
const _defaultTocBaseUrl = 'https://50ohm.de/assets/toc';

Future<void> main(List<String> arguments) async {
  final options = _options(arguments);
  if (options.containsKey('help')) {
    stderr.writeln(
      'Usage: dart run tool/update_question_assets.dart\n'
      'Optional: --question-index <URL or file> --toc-base-url <URL>',
    );
    return;
  }
  final indexSource = options['question-index'] ?? _defaultQuestionIndexUrl;
  final tocBaseUrl = options['toc-base-url'] ?? _defaultTocBaseUrl;

  final questionsDirectory = Directory('assets/questions');
  final catalogFile = File('${questionsDirectory.path}/Questions.json');
  final legacySnapshot = File('${questionsDirectory.path}/legacy_v1.json');

  if (!legacySnapshot.existsSync()) {
    throw StateError(
      '${legacySnapshot.path} is missing. It is an immutable migration asset '
      'and must never be regenerated from a newer course structure.',
    );
  }

  stdout.writeln('Loading question index from $indexSource');
  final index = await _readMap(indexSource);
  final catalog = _readLocalMap(catalogFile);

  final regularIndexIds = index.entries
      .where((entry) => _editionsIn(entry.value).contains('NEA'))
      .map((entry) => entry.key)
      .toSet();

  final questionsById = <String, Map<String, dynamic>>{};
  _visitQuestions(catalog, (question) {
    questionsById[question['number'].toString()] = question;
  });

  _expectEqualSets(
    'bundled question catalog and regular question index',
    questionsById.keys.toSet(),
    regularIndexIds,
  );

  final solutionIds = index.entries
      .where((entry) =>
          regularIndexIds.contains(entry.key) &&
          entry.value is Map &&
          entry.value['has_solution'] == true)
      .map((entry) => entry.key)
      .toList()
    ..sort();
  final generatedCourses = <String, Map<String, dynamic>>{};

  for (final edition in _editions) {
    final tocSource = '$tocBaseUrl/$edition.json';
    stdout.writeln('Loading $edition TOC from $tocSource');
    final toc = await _readMap(tocSource);
    final oldCourse = _readLocalMap(
      File('${questionsDirectory.path}/$edition.json'),
    );
    final course = <String, dynamic>{
      'title': oldCourse['title'] ?? toc['title'],
      if (oldCourse['metadata'] != null) 'metadata': oldCourse['metadata'],
      'sections': <dynamic>[],
    };

    final emittedIds = <String>{};
    for (final rawChapter in (toc['chapters'] as List).whereType<Map>()) {
      final chapter = rawChapter.cast<String, dynamic>();
      final outputSections = <dynamic>[];
      for (final rawSection in (chapter['sections'] as List).whereType<Map>()) {
        final section = rawSection.cast<String, dynamic>();
        final sectionId = section['ident'].toString();
        final ids = index.entries
            .where((entry) =>
                _editionsIn(entry.value).contains(edition) &&
                entry.value['section'] == sectionId)
            .map((entry) => entry.key)
            .toList();
        if (ids.isEmpty) continue;

        final questions = ids.map((id) {
          final source = questionsById[id];
          if (source == null) {
            throw StateError('Question $id from index is missing in catalog');
          }
          if (!emittedIds.add(id)) {
            throw StateError('Question $id occurs more than once in $edition');
          }
          return Map<String, dynamic>.from(source);
        }).toList();
        outputSections.add({
          'title': section['title'],
          'section': sectionId,
          'questions': questions,
        });
      }
      if (outputSections.isNotEmpty) {
        (course['sections'] as List).add({
          'title': chapter['title'],
          'sections': outputSections,
        });
      }
    }

    final expectedIds = index.entries
        .where((entry) => _editionsIn(entry.value).contains(edition))
        .map((entry) => entry.key)
        .toSet();
    _expectEqualSets(
        '$edition TOC and question index', emittedIds, expectedIds);
    generatedCourses[edition] = course;
  }

  // Write only after every remote source and every course passed validation.
  _writeJson(
    File('${questionsDirectory.path}/solutions.json'),
    {'question_ids': solutionIds},
  );
  for (final edition in _editions) {
    _writeJson(
      File('${questionsDirectory.path}/$edition.json'),
      generatedCourses[edition]!,
    );
    final questionCount = index.entries
        .where((entry) => _editionsIn(entry.value).contains(edition))
        .length;
    stdout.writeln(
      'Updated $edition.json ($questionCount questions).',
    );
  }
}

Map<String, String> _options(List<String> arguments) {
  final result = <String, String>{};
  for (var index = 0; index < arguments.length; index++) {
    final key = arguments[index].replaceFirst(RegExp(r'^--'), '');
    if (key == 'help') {
      result[key] = 'true';
    } else if (index + 1 < arguments.length) {
      result[key] = arguments[++index];
    } else {
      throw ArgumentError('Missing value for ${arguments[index]}');
    }
  }
  return result;
}

Map<String, dynamic> _readLocalMap(File file) =>
    (jsonDecode(file.readAsStringSync()) as Map).cast<String, dynamic>();

Future<Map<String, dynamic>> _readMap(String source) async =>
    (jsonDecode(await _readText(source)) as Map).cast<String, dynamic>();

Future<String> _readText(String source) async {
  final uri = Uri.tryParse(source);
  if (uri == null || !uri.hasScheme) return File(source).readAsString();
  if (uri.scheme != 'https') {
    throw ArgumentError.value(source, 'source', 'Only HTTPS URLs are allowed');
  }

  Object? lastError;
  for (var attempt = 1; attempt <= 3; attempt++) {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    try {
      final request = await client.getUrl(uri);
      request.persistentConnection = false;
      request.headers
        ..set(HttpHeaders.userAgentHeader, '50ohm-pocket-question-updater')
        ..set(HttpHeaders.acceptEncodingHeader, 'identity');
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException(
          'HTTP ${response.statusCode} while loading $source',
          uri: uri,
        );
      }
      return await response.transform(utf8.decoder).join();
    } catch (error) {
      lastError = error;
      if (attempt < 3) {
        await Future<void>.delayed(Duration(milliseconds: 250 * attempt));
      }
    } finally {
      client.close(force: true);
    }
  }
  throw StateError('Could not load $source after 3 attempts: $lastError');
}

List<String> _editionsIn(dynamic value) {
  if (value is! Map || value['editions'] is! List) return const [];
  return (value['editions'] as List).map((item) => item.toString()).toList();
}

void _visitQuestions(dynamic node, void Function(Map<String, dynamic>) visit) {
  if (node is Map) {
    if (node['number'] != null) visit(node.cast<String, dynamic>());
    for (final value in node.values) {
      _visitQuestions(value, visit);
    }
  } else if (node is List) {
    for (final value in node) {
      _visitQuestions(value, visit);
    }
  }
}

void _expectEqualSets(String label, Set<String> actual, Set<String> expected) {
  final missing = expected.difference(actual).toList()..sort();
  final extra = actual.difference(expected).toList()..sort();
  if (missing.isNotEmpty || extra.isNotEmpty) {
    throw StateError(
      '$label differ. Missing: ${missing.join(', ')}; extra: ${extra.join(', ')}',
    );
  }
}

void _writeJson(File file, Object value) {
  file.writeAsStringSync(
      '${const JsonEncoder.withIndent('    ').convert(value)}\n');
}
