import 'dart:convert';

import 'package:fuenfzigohm/custom_libs/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// Filters direct questions and arbitrarily nested question sections by class.
/// Empty sections are removed after filtering.
void filterQuestionSections(Map<String, dynamic> section, Set<int> classes) {
  final questions = section["questions"];
  if (questions is List) {
    questions.removeWhere((question) {
      if (question is! Map) return true;
      final questionClass = int.tryParse(question["class"].toString());
      return questionClass == null || !classes.contains(questionClass);
    });
  }

  final subsections = section["sections"];
  if (subsections is List) {
    for (final subsection in subsections.whereType<Map>()) {
      filterQuestionSections(subsection.cast<String, dynamic>(), classes);
    }
    subsections.removeWhere((subsection) =>
        subsection is! Map || !_questionSectionHasContent(subsection));
  }
}

bool _questionSectionHasContent(Map section) {
  final questions = section["questions"];
  final subsections = section["sections"];
  return questions is List && questions.isNotEmpty ||
      subsections is List && subsections.isNotEmpty;
}

/// Expands an upgrade selection to the complete target exam catalog.
///
/// Course assets use only the newly required classes for upgrades, for
/// example `{2}` for N -> E. The official catalog view, however, must also
/// contain the common class-N questions for operation and regulations.
Set<int> catalogClassesForCourse(Iterable<int> selectedClasses) {
  final classes = selectedClasses.toSet();
  if (classes.contains(3)) return {1, 2, 3};
  if (classes.contains(2)) return {1, 2};
  return {1};
}

class QuestionReference {
  final int mainChapter;
  final int chapter;
  final int? subchapter;
  final int questionIndex;
  final String questionId;

  const QuestionReference({
    required this.mainChapter,
    required this.chapter,
    required this.subchapter,
    required this.questionIndex,
    required this.questionId,
  });

  String get legacyKey => subchapter == null
      ? '[$mainChapter][$chapter]'
      : '[$mainChapter][$chapter][$subchapter]';
}

class Json {
  Map<String, dynamic>? data;
  Json(this.data);

  Future<Map<String, dynamic>> load(
      final String questionpath, int mainchapter, BuildContext context) async {
    var rawdata = await rootBundle.loadString(questionpath);
    Map<String, dynamic> importedData = jsonDecode(rawdata);
    final storedClasses =
        DatabaseWidget.of(context).settings_database.get("Klasse");
    final classes = storedClasses is Iterable
        ? storedClasses.whereType<num>().map((value) => value.toInt()).toSet()
        : <int>{};

    this.data = mainchapter == -1
        ? importedData
        : importedData["sections"][mainchapter] as Map<String, dynamic>;

    final filterClasses =
        mainchapter == -1 ? classes : catalogClassesForCourse(classes);
    filterQuestionSections(this.data!, filterClasses);
    return this.data!;
  }

  main_chapter_name() => this.data!["title"];

  chapter_names(var chapter) => this.data!["sections"][chapter]["title"];

  chaptericon(int chapter, int subchapter) => null;

  subchapter_name(int chapter, int subchapter) {
    try {
      return this.data!["sections"][chapter]["sections"][subchapter]["title"];
    } catch (e) {
      return this.data!["sections"][chapter]["title"];
    }
  }

  questionname(var chapter, var subchapter, var question) {
    try {
      return this.data!["sections"][chapter]["sections"][subchapter]
          ["questions"][question]["question"];
    } catch (e) {
      return this.data!["sections"][chapter]["questions"][question]["question"];
    }
  }

  String? questionimage(int chapter, var subchapter, int question) {
    try {
      return this.data!["sections"][chapter]["sections"][subchapter]
          ["questions"][question]["picture_question"];
    } on NoSuchMethodError catch (_) {
      return this.data!["sections"][chapter]["questions"][question]
          ["picture_question"];
    }
  }

  questionid(var chapter, var subchapter, var question) {
    try {
      return this.data!["sections"][chapter]["sections"][subchapter]
          ["questions"][question]["number"];
    } catch (e) {
      return this.data!["sections"][chapter]["questions"][question]["number"];
    }
  }

  bool imageQuestion(int chapter, var subchapter, int question) {
    try {
      if (this.data!["sections"][chapter]["sections"][subchapter]["questions"]
              [question]["picture_a"] !=
          null) {
        return true;
      }
      return false;
    } catch (_) {
      if (this.data!["sections"][chapter]["questions"][question]["picture_a"] !=
          null) {
        return true;
      }
      return false;
    }
  }

  List<String> answerList(int chapter, var subchapter, int question) {
    try {
      Map answerSection = this.data!["sections"][chapter]["sections"]
          [subchapter]["questions"][question];
      return [
        answerSection["answer_a"],
        answerSection["answer_b"],
        answerSection["answer_c"],
        answerSection["answer_d"]
      ];
    } catch (e) {
      Map answerSection =
          this.data!["sections"][chapter]["questions"][question];
      return [
        answerSection["answer_a"],
        answerSection["answer_b"],
        answerSection["answer_c"],
        answerSection["answer_d"]
      ];
    }
  }

  List<String> imageList(int chapter, var subchapter, int question) {
    try {
      Map answerSection = this.data!["sections"][chapter]["sections"]
          [subchapter]["questions"][question];
      return [
        answerSection["picture_a"],
        answerSection["picture_b"],
        answerSection["picture_c"],
        answerSection["picture_d"]
      ];
    } catch (e) {
      Map answerSection =
          this.data!["sections"][chapter]["questions"][question];
      return [
        answerSection["picture_a"],
        answerSection["picture_b"],
        answerSection["picture_c"],
        answerSection["picture_d"]
      ];
    }
  }

  subchaptersize(int chapter, int subchapter) {
    try {
      return this
          .data!["sections"][chapter]["sections"][subchapter]["questions"]
          .length;
    } catch (e) {
      return this.data!["sections"][chapter]["questions"].length;
    }
  }

  chaptersize(int chapter) {
    final sections = this.data!["sections"][chapter]["sections"];
    return sections is List ? sections.length : 0;
  }

  int chapterQuestionCount(int chapter) {
    final questions = this.data!["sections"][chapter]["questions"];
    return questions is List ? questions.length : 0;
  }

  mainchaptersize() => this.data!["sections"].length;
  // Todo fix
  percentOfChapter(List questionlist, int currentprog) =>
      (questionlist.length * currentprog) * 0.1;

  /// Returns a list of all question keys in order: [[mainchapter, chapter, subchapter, questionIndex], ...]
  /// Used to map questions to their database scores
  List<List<int>> getAllQuestionKeys(int mainchapter) {
    return getQuestionReferences(mainchapter)
        .map((reference) => [
              reference.mainChapter,
              reference.chapter,
              reference.subchapter ?? -1,
              reference.questionIndex,
            ])
        .toList();
  }

  List<QuestionReference> getQuestionReferences(int mainchapter) {
    List<QuestionReference> references = [];
    try {
      List sections = this.data!["sections"];
      for (int c = 0; c < sections.length; c++) {
        var chapter = sections[c];
        if (chapter["sections"] != null) {
          List subchapters = chapter["sections"];
          for (int s = 0; s < subchapters.length; s++) {
            var subchapter = subchapters[s];
            if (subchapter["questions"] != null) {
              int questionCount = (subchapter["questions"] as List).length;
              for (int q = 0; q < questionCount; q++) {
                references.add(QuestionReference(
                  mainChapter: mainchapter,
                  chapter: c,
                  subchapter: s,
                  questionIndex: q,
                  questionId: subchapter["questions"][q]["number"].toString(),
                ));
              }
            }
          }
        } else if (chapter["questions"] != null) {
          int questionCount = (chapter["questions"] as List).length;
          for (int q = 0; q < questionCount; q++) {
            references.add(QuestionReference(
              mainChapter: mainchapter,
              chapter: c,
              subchapter: null,
              questionIndex: q,
              questionId: chapter["questions"][q]["number"].toString(),
            ));
          }
        }
      }
    } catch (e) {
      // Return empty on error
    }
    return references;
  }

  List<String> getAllQuestionIds(int mainchapter) =>
      getQuestionReferences(mainchapter)
          .map((reference) => reference.questionId)
          .toList();

  List<String> getQuestionIds(int chapter, int? subchapter) {
    if (subchapter == null) {
      final questions = this.data!["sections"][chapter]["questions"];
      if (questions is! List) return [];
      return questions
          .map((question) => question["number"].toString())
          .toList();
    }

    final questions =
        this.data!["sections"][chapter]["sections"][subchapter]["questions"];
    if (questions is! List) return [];
    return questions.map((question) => question["number"].toString()).toList();
  }

  // Get total question count for a chapter (including all subchapters)
  int getTotalQuestionCount(int chapter) {
    final directQuestionCount = chapterQuestionCount(chapter);
    if (directQuestionCount > 0) return directQuestionCount;

    int totalCount = 0;
    final sections = this.data!["sections"][chapter]["sections"];
    if (sections is List) {
      for (final subsection in sections) {
        if (subsection is Map && subsection["questions"] is List) {
          totalCount += (subsection["questions"] as List).length;
        }
      }
    }
    return totalCount;
  }
}

class JsonWidget extends InheritedWidget {
  final Map<String, dynamic>? json;
  final int mainchapter;

  const JsonWidget(Widget child, this.json, this.mainchapter)
      : super(child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  static JsonWidget of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<JsonWidget>()!;
}
