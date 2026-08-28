import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuenfzigohm/custom_libs/json.dart';
import 'package:fuenfzigohm/custom_libs/database.dart';
import 'package:fuenfzigohm/screens/question.dart';
import 'package:fuenfzigohm/screens/question_search.dart';

class BookmarksPage extends StatefulWidget {
  @override
  _BookmarksPageState createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  List<String> _bookmarkedQuestions = const [];
  late Json json;
  List<QuestionSearchEntry> _questionIndex = const [];

  @override
  void initState() {
    super.initState();
    json = Json({});
    _loadCatalog();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBookmarks();
  }

  Future<void> _loadCatalog() async {
    try {
      final raw = await rootBundle.loadString('assets/questions/Questions.json');
      final catalog = jsonDecode(raw) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        json = Json(catalog);
        _questionIndex = buildQuestionSearchIndex(json.data);
      });
    } catch (e) {
      debugPrint('Could not load bookmarks catalog: $e');
    }
  }

  void _loadBookmarks() {
    final db = DatabaseWidget.maybeOf(context);
    if (db == null) {
      return;
    }

    final bookmarks = db.bookmarks_database.get('bookmarks') as List<dynamic>? ?? [];
    setState(() {
      _bookmarkedQuestions = List<String>.from(bookmarks);
    });
  }

  void _removeBookmark(String questionId) {
    final db = DatabaseWidget.maybeOf(context);
    if (db == null) return;

    setState(() {
      _bookmarkedQuestions.remove(questionId);
      db.bookmarks_database.put('bookmarks', _bookmarkedQuestions);
    });
  }

  Map<String, dynamic>? _findQuestionData(String questionId) {
    try {
      final normalized = normalizeQuestionNumber(questionId);
      final matches = _questionIndex.where((entry) => 
          normalizeQuestionNumber(entry.questionId) == normalized).toList();
      
      if (matches.isNotEmpty) {
        return matches.first.data;
      }
    } catch (e) {
      debugPrint('Error finding question: $e');
    }
    return null;
  }

  void _openQuestion(String questionId) {
    try {
      final questionData = _findQuestionData(questionId);
      if (questionData != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => Question.single(context, questionData),
          ),
        ).then((_) => setState(() {
          _loadBookmarks(); // Reload in case bookmark status changed
        }));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Frage $questionId nicht gefunden")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fehler beim Laden der Frage: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = List<String>.from(_bookmarkedQuestions)
      ..sort((a, b) => a.compareTo(b));

    return Scaffold(
      appBar: AppBar(
        title: Text("Gemerkerte Fragen (${questions.length})"),
        centerTitle: false,
      ),
      body: questions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Keine gemerkerten Fragen",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Merke dir Fragen für später, indem du das Bookmark-Symbol drückst.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: questions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final questionId = questions[index];
                return ListTile(
                  leading: const Icon(Icons.bookmark, color: Colors.red),
                  title: Text(questionId),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: "Aus Merkliste entfernen",
                    onPressed: () => _removeBookmark(questionId),
                  ),
                  onTap: () => _openQuestion(questionId),
                );
              },
            ),
    );
  }
}
