import 'package:flutter/material.dart';
import 'package:fuenfzigohm/components/classListTile.dart';

import 'package:fuenfzigohm/helpers/courseNavigation.dart';

class selectClass extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Was möchtest du lernen?",
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            ClassListTile(
              onTap: () =>
                  handleCourseStart(CourseClass.COURSE_CLASS_E, context),
              surfaceColor: Color(0xffFE756C),
              classTitle: "Upgrade von N auf E",
              classDescription:
                  "Du hast schon deine N Zulassung? Super! Starte heute mit deinen Vorbereitungen auf die Klasse E.",
              type: ClassListTileType.UPGRADE,
            ),
            ClassListTile(
              onTap: () =>
                  handleCourseStart(CourseClass.COURSE_CLASS_A, context),
              surfaceColor: Color(0xff3BB583),
              classTitle: "Upgrade von E auf A",
              classDescription:
                  "Du hast deine E Zulassung? Super! Starte heute mit deinen Vorbereitungen auf die Klasse A.",
              type: ClassListTileType.UPGRADE,
            ),
            ClassListTile(
              onTap: () =>
                  handleCourseStart(CourseClass.COURSE_CLASS_EA, context),
              surfaceColor: Color(0xff47ABE8),
              classTitle: "Upgrade von N auf A",
              classDescription:
                  "Du hast deine N Zulassung? Super! Starte heute mit deinen Vorbereitungen auf die Klasse A.",
              type: ClassListTileType.UPGRADE,
            ),
          ],
        ),
      ),
    );
  }
}
