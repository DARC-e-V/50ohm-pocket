import 'package:fuenfzigohm/custom_libs/section_urls.dart';
import 'package:fuenfzigohm/custom_libs/json.dart';

class CourseLesson {
  const CourseLesson({
    required this.chapter,
    required this.subchapter,
    required this.chapterTitle,
    required this.title,
    required this.questionCount,
    required this.materialUrl,
  });

  final int chapter;
  final int? subchapter;
  final String chapterTitle;
  final String title;
  final int questionCount;
  final String materialUrl;
}

/// Continue at the first unseen content; once all questions have been seen,
/// start at the last lesson so the session can review the entire course.
int continuousCourseEntryLesson(
  Map<String, dynamic> data,
  List<CourseLesson> lessons,
  Set<String> answeredQuestionIds,
) {
  final json = Json(data);
  for (var index = 0; index < lessons.length; index++) {
    final lesson = lessons[index];
    if (json
        .getQuestionIds(lesson.chapter, lesson.subchapter)
        .any((id) => !answeredQuestionIds.contains(id))) return index;
  }
  return lessons.isEmpty ? 0 : lessons.length - 1;
}

/// The same lesson order as the course overview, excluding empty lessons.
List<CourseLesson> continuousCourseLessons(
  Map<String, dynamic> data,
  String course,
) {
  final lessons = <CourseLesson>[];
  final chapters = data['sections'] as List;
  for (var chapter = 0; chapter < chapters.length; chapter++) {
    final section = chapters[chapter] as Map;
    final subsections = section['sections'] as List?;
    final rows =
        subsections == null || subsections.isEmpty ? [section] : subsections;
    for (var row = 0; row < rows.length; row++) {
      final lesson = rows[row] as Map;
      final questions = lesson['questions'] as List?;
      if (questions == null || questions.isEmpty) continue;
      final title = lesson['title'] as String;
      final slug = lesson['section'] as String?;
      lessons.add(CourseLesson(
        chapter: chapter,
        subchapter: subsections == null || subsections.isEmpty ? null : row,
        chapterTitle: section['title'] as String,
        title: title,
        questionCount: questions.length,
        materialUrl: slug != null && slug.isNotEmpty
            ? 'https://50ohm.de/${course}_$slug.html'
            : subsectionUrl(course, title) ?? 'https://50ohm.de',
      ));
    }
  }
  return lessons;
}
