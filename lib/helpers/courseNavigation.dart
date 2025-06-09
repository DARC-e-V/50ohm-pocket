import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:fuenfzigohm/coustom_libs/database.dart';

class CourseClass {
  // Basic course values as constants for easy readability
  static const CLASS_N = 1;
  static const CLASS_E = 2;
  static const CLASS_A = 3;

  // Base courses (upgrade course)
  static const COURSE_CLASS_E = {CLASS_E};
  static const COURSE_CLASS_A = {CLASS_A};
  static const COURSE_CLASS_EA = {CLASS_E, CLASS_A};
  // Full courses (entry class)
  static const COURSE_CLASS_N = {CLASS_N};
  static const COURSE_CLASS_NE = {CLASS_N, CLASS_E};
  static const COURSE_CLASS_NEA = {CLASS_N, CLASS_E, CLASS_A};

  // Helper to determine the right course material at given path
  static String getCourseResourcePath(Set<int> course) {
    if (setEquals(course, CourseClass.COURSE_CLASS_N)) {
      return 'assets/questions/N.json';
    } else if (setEquals(course, CourseClass.COURSE_CLASS_NE)) {
      return 'assets/questions/NE.json';
    } else if (setEquals(course, CourseClass.COURSE_CLASS_NEA)) {
      return 'assets/questions/NEA.json';
    } else if (setEquals(course, CourseClass.COURSE_CLASS_E)) {
      return 'assets/questions/E.json';
    } else if (setEquals(course, CourseClass.COURSE_CLASS_A)) {
      return 'assets/questions/A.json';
    } else if (setEquals(course, CourseClass.COURSE_CLASS_EA)) {
      return 'assets/questions/EA.json';
    }
    throw Exception('Invalid course provided');
  }
}

void handleCourseStart(Set<int> course, BuildContext context) {
  final selectedCourse = [...course];
  DatabaseWidget.of(context)
      .settings_database
      .put(DatabaseWidget.SETTINGS_WELCOME_PAGE_KEY, true);
  DatabaseWidget.of(context)
      .settings_database
      .put(DatabaseWidget.SETTINGS_CLASS_KEY, selectedCourse);
  Navigator.pushNamedAndRemoveUntil(context, "/learn", (r) => false);
}
