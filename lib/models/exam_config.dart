class ExamPart {
  final String name;
  final String description;
  final List<String> questionPrefixes;
  final int questionCount;
  final int timeMinutes;
  final int passThreshold;
  final int oralExamThreshold;

  const ExamPart({
    required this.name,
    required this.description,
    required this.questionPrefixes,
    required this.questionCount,
    required this.timeMinutes,
    required this.passThreshold,
    this.oralExamThreshold = -1,
  });

  ExamPartResult getResult(int correctAnswers) {
    if (correctAnswers >= passThreshold) {
      return ExamPartResult.passed;
    } else if (oralExamThreshold > 0 && correctAnswers >= oralExamThreshold) {
      return ExamPartResult.oralExam;
    } else {
      return ExamPartResult.failed;
    }
  }
}

enum ExamPartResult {
  passed,
  oralExam,
  failed,
}

extension ExamPartResultExtension on ExamPartResult {
  String get label {
    switch (this) {
      case ExamPartResult.passed:
        return 'BESTANDEN';
      case ExamPartResult.oralExam:
        return 'MÜNDLICHE NACHPRÜFUNG';
      case ExamPartResult.failed:
        return 'NICHT BESTANDEN';
    }
  }

  String get emoji {
    switch (this) {
      case ExamPartResult.passed:
        return '✅';
      case ExamPartResult.oralExam:
        return '📝';
      case ExamPartResult.failed:
        return '❌';
    }
  }
}

class ExamConfig {
  final String licenseClass;
  final String displayName;
  final List<ExamPart> parts;
  final String jsonFile;

  const ExamConfig({
    required this.licenseClass,
    required this.displayName,
    required this.parts,
    required this.jsonFile,
  });

  int get totalQuestions => parts.fold(0, (sum, part) => sum + part.questionCount);

  int get totalTimeMinutes => parts.fold(0, (sum, part) => sum + part.timeMinutes);
}
class ExamConfigs {
  static const klasseN = ExamConfig(
    licenseClass: 'N',
    displayName: 'Klasse N',
    jsonFile: 'assets/questions/N.json',
    parts: [
      ExamPart(
        name: 'Technik Klasse N',
        description: 'Technische Kenntnisse',
        questionPrefixes: ['N'],
        questionCount: 25,
        timeMinutes: 45,
        passThreshold: 19,
        oralExamThreshold: 17,
      ),
      ExamPart(
        name: 'Betriebstechnik',
        description: 'Betriebliche Kenntnisse',
        questionPrefixes: ['B'],
        questionCount: 25,
        timeMinutes: 45,
        passThreshold: 19,
        oralExamThreshold: 17,
      ),
      ExamPart(
        name: 'Vorschriften',
        description: 'Gesetze und Vorschriften',
        questionPrefixes: ['V'],
        questionCount: 25,
        timeMinutes: 45,
        passThreshold: 19,
        oralExamThreshold: 17,
      ),
    ],
  );

  static const klasseE = ExamConfig(
    licenseClass: 'E',
    displayName: 'Klasse E',
    jsonFile: 'assets/questions/NE.json',
    parts: [
      ExamPart(
        name: 'Technik Klasse E',
        description: 'Technische Kenntnisse',
        questionPrefixes: ['E'],
        questionCount: 50,
        timeMinutes: 90,
        passThreshold: 37,
        oralExamThreshold: -1,
      ),
      ExamPart(
        name: 'Betriebstechnik',
        description: 'Betriebliche Kenntnisse',
        questionPrefixes: ['B'],
        questionCount: 25,
        timeMinutes: 45,
        passThreshold: 18,
        oralExamThreshold: -1,
      ),
      ExamPart(
        name: 'Vorschriften',
        description: 'Gesetze und Vorschriften',
        questionPrefixes: ['V'], // VA, VB, VC, VD, VE
        questionCount: 25,
        timeMinutes: 45,
        passThreshold: 18,
        oralExamThreshold: -1,
      ),
    ],
  );

  static const klasseA = ExamConfig(
    licenseClass: 'A',
    displayName: 'Klasse A',
    jsonFile: 'assets/questions/NEA.json',
    parts: [
      ExamPart(
        name: 'Technik Klasse A',
        description: 'Technische Kenntnisse',
        questionPrefixes: ['A'],
        questionCount: 50,
        timeMinutes: 90,
        passThreshold: 37,
      ),
      ExamPart(
        name: 'Betriebstechnik',
        description: 'Betriebliche Kenntnisse',
        questionPrefixes: ['B'],
        questionCount: 25,
        timeMinutes: 45,
        passThreshold: 18,
      ),
      ExamPart(
        name: 'Vorschriften',
        description: 'Gesetze und Vorschriften',
        questionPrefixes: ['V'],
        questionCount: 25,
        timeMinutes: 45,
        passThreshold: 18,
      ),
    ],
  );

  static List<ExamConfig> get all => [klasseN, klasseE, klasseA];

  static ExamConfig? getByClass(String licenseClass) {
    switch (licenseClass.toUpperCase()) {
      case 'N':
        return klasseN;
      case 'E':
        return klasseE;
      case 'A':
        return klasseA;
      default:
        return null;
    }
  }
}
