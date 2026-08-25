import 'package:flutter_test/flutter_test.dart';

import 'package:fuenfzigohm/custom_libs/json.dart';
import 'package:fuenfzigohm/screens/chapterSelection.dart';

void main() {
  test('lesson list maps all chapters without skipping or exceeding bounds',
      () {
    final json = Json({
      'sections': List.generate(14, (index) => {'title': 'Chapter $index'}),
    });
    final chapterCount = json.mainchaptersize() as int;
    final itemCount = lessonListItemCount(chapterCount);

    final chapterIndexes = [
      for (int itemIndex = lessonListHeaderItemCount;
          itemIndex < itemCount;
          itemIndex++)
        lessonChapterIndex(itemIndex),
    ];

    expect(itemCount, 16);
    expect(chapterIndexes, List.generate(14, (index) => index));
    expect(chapterIndexes.first, 0);
    expect(chapterIndexes.last, 13);
  });
}
