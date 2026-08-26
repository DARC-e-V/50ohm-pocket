import "package:html/parser.dart";
import "package:html/dom.dart" as dom;
import 'dart:math';

import 'package:fuenfzigohm/constants.dart';
import 'package:fuenfzigohm/custom_libs/database.dart';
import 'package:fuenfzigohm/custom_libs/json.dart';
import 'package:fuenfzigohm/custom_libs/section_urls.dart';
import 'package:fuenfzigohm/custom_libs/solution_index.dart';
import 'package:fuenfzigohm/custom_libs/url_launcher.dart';
import 'package:fuenfzigohm/custom_libs/video_index.dart';
import 'package:fuenfzigohm/learning_state/practice_question_selector.dart';
import 'package:fuenfzigohm/screens/completeLesson.dart';
import 'package:fuenfzigohm/screens/pdfViewer.dart';
import 'package:fuenfzigohm/screens/chapterSelection.dart';
import 'package:fuenfzigohm/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/semantics.dart';

enum QuestionState{
  answering,
  evaluating
}
class Question extends StatefulWidget {

  final List subchapter;
  final int chapter;
  final BuildContext context;
  final Map<String, dynamic>? practiceData;
  final List<QuestionReference> practiceQuestions;
  final QuestionReference? singleQuestion;

  Question(this.context, this.subchapter,this.chapter)
      : practiceData = null,
        practiceQuestions = const [],
        singleQuestion = null;

  Question.practice(
      this.context,
      Map<String, dynamic> data,
      List<QuestionReference> questions,
      ) : subchapter = const [],
        chapter = 0,
        practiceData = data,
        practiceQuestions = questions,
        singleQuestion = null;

  Question.single(
      this.context,
      Map<String, dynamic> question,
      ) : subchapter = const [],
        chapter = 0,
        practiceData = {
          "title": "Suchergebnis",
          "sections": [
            {
              "title": "Suchergebnis",
              "questions": [question],
            }
          ],
        },
        practiceQuestions = const [],
        singleQuestion = QuestionReference(
          mainChapter: -1,
          chapter: 0,
          subchapter: null,
          questionIndex: 0,
          questionId: "${question['number']}",
        );

  @override
  createState() => _Questionstate(this.context, this.subchapter,this.chapter);
}
class _Questionstate extends State<Question> with TickerProviderStateMixin {

  var questionorder, questreslist, pdfController, questionradio;

  final ScrollController _questionScrollController = ScrollController();

  QuestionState state = QuestionState.answering;

  int highlighting = -1;
  bool _isBookmarked = false;

  late int questionkey, subchapterkey;
  late List<String> ShuffledAnswers, Answers;

  final List subchapter;
  final context, chapter;

  late Json json;
  late final PracticeQuestionSelector _practiceSelector;
  QuestionReference? _practiceReference;
  int _practiceAnswered = 0;
  bool imageQuestion = false;
  bool correct = false;
  OverlayEntry? overlayEntry;


  _Questionstate(this.context, this.subchapter,this.chapter);

  @override
  void dispose() {
    _questionScrollController.dispose();
    super.dispose();
  }

  bool get _isPractice =>
      widget.practiceData != null && widget.singleQuestion == null;

  bool get _isSingle => widget.singleQuestion != null;

  int get _chapter =>
      widget.singleQuestion?.chapter ?? _practiceReference?.chapter ?? chapter;

  get _subchapter => _isSingle
      ? widget.singleQuestion!.subchapter
      : _isPractice
          ? _practiceReference?.subchapter
          : subchapter.isEmpty ? null : subchapter[subchapterkey];

  int get _questionIndex =>
      widget.singleQuestion?.questionIndex ??
      _practiceReference?.questionIndex ??
      questionorder[questionkey];

  String get _questionId =>
      json.questionid(_chapter, _subchapter, _questionIndex).toString();

  @override
  initState() {
    questreslist = List.generate(subchapter.length == 0 ? 1 :subchapter.length, (index) => List.empty(growable: true));
    questionkey = 0;
    subchapterkey = 0;
    setState(() {
      json = Json(widget.practiceData ?? JsonWidget.of(context).json);

      if (_isSingle) {
        questionorder = <int>[widget.singleQuestion!.questionIndex];
      } else if (_isPractice) {
        _practiceSelector = PracticeQuestionSelector();
        questionorder = <int>[];
        _selectNextPracticeQuestion();
      } else if(subchapter.length == 0) questionorder = orderlist(json.chapterQuestionCount(chapter), true);
      else questionorder = orderlist(json.subchaptersize(chapter,subchapter[subchapterkey]), true);

      refreshAnswers();
      _isBookmarked = _checkIsBookmarked();

    });
    // print("chapterorder" + "$chapterorder");
    super.initState();
  }

  refreshAnswers(){
    setState(() {
      imageQuestion = json.imageQuestion(_chapter, _subchapter, _questionIndex);
      if(imageQuestion){
        Answers = json.imageList(_chapter, _subchapter, _questionIndex);
      }else{
        Answers = json.answerList(_chapter, _subchapter, _questionIndex);
      }

      ShuffledAnswers = [];
      ShuffledAnswers.addAll(Answers);
      ShuffledAnswers.shuffle();

      highlighting = -1;
      state = QuestionState.answering;
      _isBookmarked = _checkIsBookmarked();
    });
  }

  bool _checkIsBookmarked() {
    final db = DatabaseWidget.maybeOf(context);
    if (db == null) return false;
    final bookmarks = db.bookmarks_database.get('bookmarks') as List<dynamic>? ?? [];
    return bookmarks.contains(_questionId);
  }

  void _toggleBookmark() {
    final db = DatabaseWidget.maybeOf(context);
    if (db == null) return;

    setState(() {
      final bookmarks = db.bookmarks_database.get('bookmarks') as List<dynamic>? ?? [];
      final bookmarksList = List<String>.from(bookmarks);

      if (bookmarksList.contains(_questionId)) {
        bookmarksList.remove(_questionId);
      } else {
        bookmarksList.add(_questionId);
      }

      db.bookmarks_database.put('bookmarks', bookmarksList);
      _isBookmarked = bookmarksList.contains(_questionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: (){
              try{
                overlayEntry!.remove();
              }catch(e){}
              Navigator.of(context).pop(true);
            },
          ),
          backgroundColor: const Color.fromARGB(10, 0, 0, 0),
          titleSpacing: 0,
          title: Row(
            children: [
              IconButton(
                icon: Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: _isBookmarked 
                      ? Colors.red 
                      : Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white 
                          : Colors.black,
                ),
                tooltip: _isBookmarked ? "Aus Merkliste entfernen" : "Zu Merkliste hinzufügen",
                onPressed: _toggleBookmark,
              ),
              Expanded(
                child: Tooltip(
                  message: "Frage $_questionId",
                  child: Text(
                    _questionId,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (!_isSingle) SizedBox(width: 8),
              if (!_isSingle) Semantics(
                label: _isPractice
                    ? "Frage ${_practiceAnswered + 1}"
                    : "Frage ${questionkey + 1} von ${questionorder.length}",
                child: ExcludeSemantics(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: main_col.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _isPractice
                          ? "${_practiceAnswered + 1}"
                          : "${questionkey + 1}/${questionorder.length}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            if (SolutionIndex.hasSolution(_questionId))
              IconButton(
                icon: Icon(Icons.lightbulb, color: Colors.amber),
                tooltip: "Lösungshinweis auf 50ohm.de",
                onPressed: () => launchURL(_getSolutionUrl()),
              ),
            if (VideoIndex.hasVideo(_questionId))
              IconButton(
                icon: Icon(Icons.smart_display, color: Colors.red),
                tooltip: "Lernvideo von DL2YMR",
                onPressed: () => launchURL(VideoIndex.urlFor(_questionId)!),
              ),
            if (DatabaseWidget.of(context).settings_database.get("courseOrdering") ?? true)
              IconButton(
                icon: Icon(Icons.menu_book),
                tooltip: "50Ω Lernmaterial",
                onPressed: () => launchURL(_getSectionUrl()),
              ),
            IconButton(
              icon: Icon(Icons.description),
              tooltip: "Hilfsmittel",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PdfViewer(
                      1,
                      "assets/pdf/Hilfsmittel_12062024.pdf",
                      "Hilfsmittel",
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              ListView(
                controller: _questionScrollController,
                children: [
                  //LinearProgressIndicator(value: json.procentofchapter(answerorder, questionkey),),
                  Padding(
                    padding: EdgeInsets.only(top: std_padding, left: std_padding, right: std_padding),
                    child: Center(
                      child: Text.rich(
                        TextSpan(
                            children: parseTextWithMath(
                              "${json.questionname(_chapter, _subchapter, _questionIndex)}",
                              TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 22,
                              ),
                            )
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  json.questionimage(_chapter, _subchapter, _questionIndex) != null
                      ? questionImage(context, json.questionimage(_chapter,_subchapter, _questionIndex)!)
                      : SizedBox(),
                  Divider(height: std_padding * 2,),
                  imageQuestion
                      ? radioSvgListBuilder()
                      : radioTextListBuilder(),
                  SizedBox(height: 200),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10, left: 8, right: 8),
                  child: ElevatedButton(
                    style: buttonstyle(main_col),
                    onPressed: () async {
                      if(state == QuestionState.answering && questionradio != null){
                        await _questionhandler(
                          ShuffledAnswers,
                          Answers,
                          questionradio,
                        );
                      }
                    },
                    child: Text("Überprüfen", style: TextStyle(color: Colors.black),),
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }


  String _getSectionUrl() {
    final selectedClasses = List<int>.from(
      DatabaseWidget.of(context).settings_database.get("Klasse") ?? [1, 2, 3],
    );
    final course = courseIdFromSelectedClasses(selectedClasses);
    final subsectionTitle = _subchapter == null
        ? json.chapter_names(_chapter).toString()
        : json.subchapter_name(_chapter, _subchapter).toString();
    return subsectionUrl(course, subsectionTitle) ?? 'https://50ohm.de';
  }

  String _getSolutionUrl() {
    return SolutionIndex.urlFor(_questionId);
  }

  Widget questionImage(BuildContext context, String url, {bool useDarkForeground = false, String semanticsLabel = "Diagramm"}) {
    List<String> illegalImages = ["BE207_q", "NF106_q", "BE209_q", "NF104_q", "NF102_q", "NF105_q", "BE208_q", "NE209_q", "NG302_q", "NF103_q", "NF101_q"];
    Widget image;
    double imageScaleWidth = min(MediaQuery.sizeOf(context).width * 0.8, 500);
    ColorFilter colorFilter =
    Theme.of(context).brightness == Brightness.dark && !useDarkForeground
        ? ColorFilter.matrix(<double>[
      -1.0, 0.0, 0.0, 0.0, 255.0,
      0.0, -1.0, 0.0, 0.0, 255.0,
      0.0, 0.0, -1.0, 0.0, 255.0,
      0.0, 0.0, 0.0, 1.0, 0.0,
    ])
        : ColorFilter.matrix(<double>[
      1.0, 0.0, 0.0, 0.0, 0.0,
      0.0, 1.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 1.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 1.0, 0.0,
    ]);

    if(illegalImages.contains(url)){
      image = Padding(
        padding: const EdgeInsets.all(8.0),
        child: ColorFiltered(
            colorFilter: colorFilter,
            child: Image.asset("assets/svgs/$url.png",
                width: imageScaleWidth)
        ),
      );
    } else {
      image = SvgPicture.asset(
          "assets/svgs/$url.svg",
          colorFilter: colorFilter,
          width: imageScaleWidth
      );
    };
    return Semantics(
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(20.0),
          maxScale: 1.6,
          panEnabled: false,
          child: image,
        ),
      ),
    );
  }
  Color _answerBackgroundColor(int answerIndex) {
    if (state != QuestionState.evaluating) {
      return Colors.transparent;
    }

    if (answerIndex == highlighting) {
      return correctFeedbackColor;
    }

    if (answerIndex == questionradio) {
      return incorrectFeedbackColor;
    }

    return Colors.transparent;
  }

  bool _isFeedbackAnswer(int answerIndex) {
    return state == QuestionState.evaluating &&
        (answerIndex == highlighting || answerIndex == questionradio);
  }

  Color? _answerForegroundColor(int answerIndex) {
    return _isFeedbackAnswer(answerIndex) ? Colors.black87 : null;
  }

  Widget? _answerStatusIcon(int answerIndex) {
    if (state != QuestionState.evaluating) {
      return null;
    }

    if (answerIndex == highlighting) {
      return Icon(Icons.check_circle, color: Colors.green.shade800);
    }

    if (answerIndex == questionradio) {
      return Icon(Icons.cancel, color: Colors.red.shade800);
    }

    return null;
  }

  ListView radioSvgListBuilder() {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        addAutomaticKeepAlives: true,
        shrinkWrap: true,
        itemCount: 4,
        itemBuilder: (context, i){
          return Container(
            decoration: BoxDecoration(
              color: _answerBackgroundColor(i),
            ),
            child: Semantics(
              label: "Antwort ${i + 1} von 4",
              selected: i == questionradio,
              child: RadioListTile(
                fillColor: MaterialStateColor.resolveWith((states) => main_col),
                activeColor: main_col,
                enableFeedback: true,
                groupValue: questionradio,
                value: i,
                onChanged: (var value) {
                  if(state == QuestionState.answering){
                    setState(() {
                      questionradio = i;
                    });
                  }
                },
                secondary: _answerStatusIcon(i),
                title: ExcludeSemantics(
                  child: questionImage(
                    context,
                    ShuffledAnswers[i],
                    useDarkForeground: _isFeedbackAnswer(i),
                  ),
                ),
              ),
            ),
          );
        }
    );
  }

  ListView radioTextListBuilder() {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        addAutomaticKeepAlives: true,
        shrinkWrap: true,
        itemCount: 4,
        itemBuilder: (context, i){
          return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: _answerBackgroundColor(i),
                  ),
                  child: RadioListTile(
                      enableFeedback: true,
                      fillColor: MaterialStateColor.resolveWith((states) => main_col),
                      activeColor: main_col,
                      groupValue: questionradio,
                      value: i,
                      onChanged: (var value) {
                        if(state == QuestionState.answering){
                          setState(() {
                            questionradio = i;
                          });
                        }
                      },
                      secondary: _answerStatusIcon(i),
                      title: Text.rich(
                        TextSpan(
                            children: parseTextWithMath(
                              "${ShuffledAnswers[i]}",
                              TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 22,
                                  color: _answerForegroundColor(i),
                              ),
                            )
                        ),
                        textAlign: TextAlign.left,
                      )
                  ),
                ),
              ]
          );
        }
    );
  }
  Future<void> _questionhandler(ShuffledAnswers, Answers, i) async {
    setState(() {
      state = QuestionState.evaluating;
    });
    bool correct = ShuffledAnswers[i] == Answers[0];
    // print("${_json.correctanswer(this.chapter,this.subchapter[this.subchapterkey],this.question[this.questionkey])}");
    questreslist[subchapterkey].add(correct);

    final selectedAnswerIndex = Answers.indexOf(ShuffledAnswers[i]);
    final selectedAnswerKey = selectedAnswerIndex >= 0
        ? ['a', 'b', 'c', 'd'][selectedAnswerIndex]
        : null;
    await DatabaseWidget.of(context).learningStateRepository.recordAnswer(
      questionId: _questionId,
      correct: correct,
      selectedAnswerKey: selectedAnswerKey,
    );

    for(int i = 0; i < ShuffledAnswers.length; i++){
      if(ShuffledAnswers[i] == Answers[0]){
        setState(() {
          highlighting = i;
        });
        break;
      };
    }
    if(correct){
      _overlay(false, "Richtig!");
    }
    else{
      final hasMath = Answers[0].contains(RegExp(r'\$[^$]+\$'));
      final announcement = (imageQuestion || hasMath)
          ? "Falsch."
          : "Falsch. Die richtige Antwort ist: ${_plainText(Answers[0])}";
      _overlay(true, announcement);
    }
  }

  String _plainText(String raw) {
    return parse(raw).body?.text ?? raw;
  }

  _overlay(bool wrong, String announcement) {
    SemanticsService.announce(announcement, TextDirection.ltr);

    OverlayState? overlayState = Overlay.of(context);

    overlayEntry = OverlayEntry(
      builder: (buildcontext){
        return  Container(
            child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: wrong ? Colors.red.shade700 : Colors.green.shade700,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 90, right: 20, left: 20),
                        child:
                        RichText(
                          textAlign: TextAlign.left,
                          text: TextSpan(
                              children: parseTextWithMath(
                                wrong ? "Die Antwort ist falsch!" : "Richtig!",
                                TextStyle(
                                    fontFamily: "Roboto",
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: 30,
                                    decoration: TextDecoration.none
                                ),
                              )
                          ),
                        ),
                      ),
                    )
                ),
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10, left: 8, right: 8),
                    child: ElevatedButton(
                      autofocus: true,
                      style: buttonstyle(wrong ? Colors.red.shade300 : Colors.green.shade300),
                      onPressed: (){
                        overlayEntry!.remove();
                        _nextquest();
                      },
                      child: Text("Weiter", style: TextStyle(color: Colors.black),),
                    ),
                  ),
                ),
              ],
            )
        );
      },
    );
    overlayState.insert(overlayEntry!);
  }
  _nextquest(){
    if (_isSingle) {
      Navigator.of(context).pop(true);
      return;
    }

    if (_questionScrollController.hasClients) {
      _questionScrollController.jumpTo(
        _questionScrollController.position.minScrollExtent,
      );
    }

    if (_isPractice) {
      questionradio = null;
      _practiceAnswered += 1;
      _selectNextPracticeQuestion();
      refreshAnswers();
      return;
    }
    try{
      this.questionorder[this.questionkey + 1];
      this.questionradio = null;
      setState(() {
        questionradio = null;
        questionkey += 1;
        refreshAnswers();
      });
    }catch(e){
      try{
        this.subchapter[this.subchapterkey];
        setState(() {
          questionradio = null;
          subchapterkey += 1;
          questionorder = buildquestionlist(chapter, subchapter[subchapterkey], json, true);
          questionkey = 0;
          refreshAnswers();
        });
      }catch(e){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (con) => Finish(chapter,subchapter, questreslist, context)),
        );

      }
    }
  }

  void _selectNextPracticeQuestion() {
    final previousQuestionId = _practiceReference?.questionId;
    final nextQuestionId = _practiceSelector.nextQuestionId(
      courseQuestionIds:
          widget.practiceQuestions.map((reference) => reference.questionId),
      repository: DatabaseWidget.of(context).learningStateRepository,
      previousQuestionId: previousQuestionId,
    );
    if (nextQuestionId == null) {
      throw StateError('No answered question is available for practice.');
    }
    _practiceReference = widget.practiceQuestions.firstWhere(
      (reference) => reference.questionId == nextQuestionId,
    );
  }

}

orderlist(var elements, bool random){
  int i = 0; List<int> orderlist = List.generate((elements),(generator) {i++; return i - 1;});

  if(!random) return orderlist;
  else orderlist.shuffle(); return orderlist;
}



List<InlineSpan> parseTextWithMath(String input, TextStyle Textstyle) {
  List<InlineSpan> widgets = [];
  List<String> parts = input.split('\$');

  for (int i = 0; i < parts.length; i++) {
    if (i % 2 == 0) {
      if (parts[i].isNotEmpty) {
          widgets.addAll(parseHtml(parts[i], Textstyle));
      }
    } else {
      widgets.add(WidgetSpan(
        child: Padding(
          padding: const EdgeInsets.only(right: 6.0),
          child: _BreakableMath(
            expression: parts[i],
            textStyle: Textstyle,
          ),
        ),
        alignment: PlaceholderAlignment.middle,
      ));
    }
  }

  return widgets;
}

class _BreakableMath extends StatelessWidget {
  final String expression;
  final TextStyle textStyle;

  const _BreakableMath({
    required this.expression,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final parts = Math.tex(
      expression,
      textStyle: textStyle,
    ).texBreak().parts;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: parts.map((part) {
            if (!constraints.hasBoundedWidth) return part;
            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: part,
              ),
            );
          }).toList(growable: false),
        );
      },
    );
  }
}

List<InlineSpan> parseHtml(String htmlString, TextStyle style) {
  var document = parse(htmlString);
  List<InlineSpan> spans = [];

  for (var node in document.body!.nodes) {
    if (node is dom.Text) {
      if (node.text.isNotEmpty) {
        spans.add(TextSpan(text: node.text, style: style));
      }
    } else if (node is dom.Element) {
       TextStyle newStyle = style;
       if (node.localName == 'b' || node.localName == 'strong') {
         newStyle = style.copyWith(fontWeight: FontWeight.bold);
       } else if (node.localName == 'i' || node.localName == 'em') {
         newStyle = style.copyWith(fontStyle: FontStyle.italic);
       } else if (node.localName == 'u' || node.localName == 'ins') {
         newStyle = style.copyWith(decoration: TextDecoration.underline);
       } else if (node.localName == 'br') {
          spans.add(TextSpan(text: "\n", style: style));
          continue;
       }
       
       if (node.hasChildNodes()) {
          for(var child in node.nodes) {
              if (child is dom.Text) {
                  spans.add(TextSpan(text: child.text, style: newStyle));
              } else if (child is dom.Element) {
                   if (child.localName == 'br') {
                      spans.add(TextSpan(text: "\n", style: newStyle));
                   } else {
                       spans.add(TextSpan(text: child.text, style: newStyle));
                   }
              }
          }
       } else {
          if(node.text.isNotEmpty) {
              spans.add(TextSpan(text: node.text, style: newStyle));
          }
       }
    }
  }
  return spans;
}
