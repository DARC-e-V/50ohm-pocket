import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';

const _courseIds = <String>{'N', 'E', 'NE', 'A', 'EA', 'NEA'};

Future<void> main(List<String> arguments) async {
  final options = _parseArguments(arguments);
  final dataDirectory = options['data-dir'];
  if (dataDirectory == null) {
    stderr.writeln(
      'Usage: dart tool/seed_learning_state.dart '
      '--data-dir <Hive directory> [--course N|E|NE|A|EA|NEA]',
    );
    exitCode = 64;
    return;
  }

  Hive.init(dataDirectory);
  final settingsBox = await Hive.openBox<dynamic>('settings');
  final eventsBox = await Hive.openBox<dynamic>('learning_events_v1');

  try {
    final courseId = options['course'] ?? _selectedCourse(settingsBox);
    if (!_courseIds.contains(courseId)) {
      throw StateError('Unsupported course: $courseId');
    }

    final courseFile = File('assets/questions/$courseId.json');
    final course = jsonDecode(await courseFile.readAsString());
    final groups = _questionGroups(course);
    final deviceId = settingsBox.get('learningStateDeviceId')?.toString() ??
        'local-test-seed';
    final now = DateTime.now().toUtc();
    final events = <String, Map<String, dynamic>>{};
    var learned = 0;
    var working = 0;
    var open = 0;

    for (final group in groups) {
      final ids = [...group]..sort((a, b) {
          final comparison = _stableHash(a).compareTo(_stableHash(b));
          return comparison != 0 ? comparison : a.compareTo(b);
        });
      final learnedCount = (ids.length * 0.2).round();
      final workingCount =
          (ids.length * 0.4).round().clamp(0, ids.length - learnedCount);

      for (var index = 0; index < ids.length; index++) {
        final questionId = ids[index];
        final score = index < learnedCount
            ? 3
            : index < learnedCount + workingCount
                ? 1 + (index % 2)
                : 0;

        if (score == 3) {
          learned++;
        } else if (score > 0) {
          working++;
        } else {
          open++;
        }

        for (var attempt = 1; attempt <= score; attempt++) {
          final id = 'test-seed:$courseId:$questionId:$attempt';
          events[id] = {
            'schemaVersion': 1,
            'id': id,
            'questionId': questionId,
            'answeredAtUtc': now.toIso8601String(),
            'recordedAtUtc': now.toIso8601String(),
            'correct': true,
            'selectedAnswerKey': 'a',
            'catalogVersion': 'afu-2024-03',
            'deviceId': deviceId,
            'source': 'testSeed',
            'legacySourceKey': null,
          };
        }
      }
    }

    await eventsBox.clear();
    await eventsBox.putAll(events);
    await eventsBox.flush();

    final total = learned + working + open;
    stdout.writeln('Seeded course $courseId with $total questions:');
    stdout.writeln(
      '  Learned: $learned (${_percent(learned, total)}%)',
    );
    stdout.writeln(
      '  In progress: $working (${_percent(working, total)}%)',
    );
    stdout.writeln('  Open: $open (${_percent(open, total)}%)');
    stdout.writeln('  Stored answer events: ${events.length}');
  } finally {
    await eventsBox.close();
    await settingsBox.close();
  }
}

Map<String, String> _parseArguments(List<String> arguments) {
  final options = <String, String>{};
  for (var index = 0; index < arguments.length; index += 2) {
    if (index + 1 >= arguments.length || !arguments[index].startsWith('--')) {
      throw const FormatException('Arguments must be --name value pairs.');
    }
    options[arguments[index].substring(2)] = arguments[index + 1];
  }
  return options;
}

String _selectedCourse(Box<dynamic> settingsBox) {
  final stored = settingsBox.get('Klasse');
  final classes = stored is Iterable
      ? stored.whereType<num>().map((value) => value.toInt()).toList()
      : <int>[1];
  classes.sort();
  return switch (classes.join(',')) {
    '1' => 'N',
    '1,2' => 'NE',
    '1,2,3' => 'NEA',
    '2' => 'E',
    '2,3' => 'EA',
    '3' => 'A',
    _ => 'N',
  };
}

List<List<String>> _questionGroups(dynamic root) {
  final groups = <List<String>>[];

  void visit(dynamic value) {
    if (value is Map) {
      final questions = value['questions'];
      if (questions is List) {
        groups.add([
          for (final question in questions)
            if (question is Map && question['number'] is String)
              question['number'] as String,
        ]);
      }
      for (final child in value.values) {
        if (!identical(child, questions)) visit(child);
      }
    } else if (value is List) {
      for (final child in value) {
        visit(child);
      }
    }
  }

  visit(root);
  return groups.where((group) => group.isNotEmpty).toList();
}

int _stableHash(String value) {
  var hash = 0x811c9dc5;
  for (final byte in utf8.encode(value)) {
    hash ^= byte;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash;
}

String _percent(int value, int total) =>
    total == 0 ? '0.0' : (value * 100 / total).toStringAsFixed(1);
