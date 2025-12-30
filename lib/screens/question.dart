import 'dart:math';

import 'package:fuenfzigohm/constants.dart';
import 'package:fuenfzigohm/coustom_libs/json.dart';
import 'package:fuenfzigohm/screens/completeLesson.dart';
import 'package:fuenfzigohm/screens/pdfViewer.dart';
import 'package:fuenfzigohm/screens/chapterSelection.dart';
import 'package:fuenfzigohm/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

enum QuestionState{
  answering,
  evaluating
}

class Question extends StatefulWidget {

  var subchapter, chapter;
  final BuildContext context;

  Question(this.context, this.subchapter,this.chapter);

  @override
  createState() => _Questionstate(this.context, this.subchapter,this.chapter);
}
class _Questionstate extends State<Question> with TickerProviderStateMixin {

  var questionorder, questreslist, pdfController, questionradio;

  QuestionState state = QuestionState.answering;

  int highlighting = -1;

  late int questionkey, subchapterkey;
  late List<String> ShuffledAnswers, Answers;

  final List subchapter;
  final context, chapter;

  late Json json;
  bool imageQuestion = false;
  bool correct = false;
  OverlayEntry? overlayEntry;


  _Questionstate(this.context, this.subchapter,this.chapter);

  @override
  initState() {
    questreslist = List.generate(subchapter.length == 0 ? 1 :subchapter.length, (index) => List.empty(growable: true));
    questionkey = 0;
    subchapterkey = 0;
    setState(() {
      json = Json(JsonWidget.of(context).json);

      if(subchapter.length == 0) questionorder = orderlist(json.chaptersize(chapter), true);
      else questionorder = orderlist(json.subchaptersize(chapter,subchapter[subchapterkey]), true);

      refreshAnswers();

    });
    // print("chapterorder" + "$chapterorder");
    super.initState();
  }

  refreshAnswers(){
    setState(() {
      imageQuestion = json.imageQuestion(chapter,subchapter.length == 0 ? Null : subchapter[subchapterkey], questionorder[questionkey]);
      if(imageQuestion){
        Answers = json.imageList(chapter,subchapter.length == 0 ? Null : subchapter[subchapterkey], questionorder[questionkey]);
      }else{
        Answers = json.answerList(chapter,subchapter.length == 0 ? Null : subchapter[subchapterkey],questionorder[questionkey]);
      }

      ShuffledAnswers = [];
      ShuffledAnswers.addAll(Answers);
      ShuffledAnswers.shuffle();

      highlighting = -1;

      state = QuestionState.answering;
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
              Navigator.of(context).pop();
            },
          ),
          backgroundColor: const Color.fromARGB(10, 0, 0, 0),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "Frage "
                        + "${json.questionid(chapter,subchapter.length == 0 ? Null : subchapter[subchapterkey], questionorder[questionkey])}",
                  ),
                  SizedBox(width: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: main_col.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${questionkey + 1}/${questionorder.length}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(icon: Icon(Icons.description), onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PdfViewer(1, "assets/pdf/Hilfsmittel_12062024.pdf", "Hilfsmittel"),
                        )
                    );
                  },
                  ),
                ],
              )
            ],
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              ListView(
                children: [
                  //LinearProgressIndicator(value: json.procentofchapter(answerorder, questionkey),),
                  Padding(
                    padding: EdgeInsets.only(top: std_padding, left: std_padding, right: std_padding),
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                            children: parseTextWithMath(
                              "${json.questionname(chapter,subchapter.length == 0 ? Null : subchapter[subchapterkey], questionorder[questionkey])}",
                              TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 22
                              ),
                            )
                        ),
                      ),
                    ),
                  ),
                  json.questionimage(chapter,subchapter.length == 0 ? Null : subchapter[subchapterkey], questionorder[questionkey]) != null
                      ? questionImage(context, json.questionimage(chapter,subchapter.length == 0 ? Null : subchapter[subchapterkey], questionorder[questionkey])!)
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
                    autofocus: false,
                    style: buttonstyle(main_col),
                    onPressed: () {
                      if(state == QuestionState.answering && questionradio != null){
                        _questionhandler(ShuffledAnswers, Answers, questionradio);
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

  _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch');
    }
  }

  InteractiveViewer questionImage(BuildContext context, String url) {
    List<String> illegalImages = ["BE207_q", "NF106_q", "BE209_q", "NF104_q", "NF102_q", "NF105_q", "BE208_q", "NE209_q", "NG302_q", "NF103_q", "NF101_q"];
    Widget image;
    double imageScaleWidth = min(MediaQuery.sizeOf(context).width * 0.8, 500);
    ColorFilter colorFilter =
    MediaQuery.of(context).platformBrightness == Brightness.dark
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
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(20.0),
      maxScale: 1.6,
      panEnabled: false,
      child: image,
    );
  }
  ListView radioSvgListBuilder() {
    Color questionColor = MediaQuery.of(context).platformBrightness == Brightness.dark ?Color.fromARGB(135, 0, 94, 255) : Colors.blue.shade200;
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        addAutomaticKeepAlives: true,
        shrinkWrap: true,
        itemCount: 4,
        itemBuilder: (context, i){
          return Container(
            decoration: BoxDecoration(
              color: i == highlighting ? questionColor : Colors.transparent,
            ),
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
              title: questionImage(context, ShuffledAnswers[i]),
            ),
          );
        }
    );
  }

  ListView radioTextListBuilder() {
    Color questionColor = MediaQuery.of(context).platformBrightness == Brightness.dark ?Color.fromARGB(135, 0, 94, 255) : Colors.blue.shade200;

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
                    color: i == highlighting ? questionColor  : Colors.transparent,
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
                      title: RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                            children: parseTextWithMath(
                              "${ShuffledAnswers[i]}",
                              TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 22
                              ),
                            )
                        ),
                      )
                  ),
                ),
              ]
          );
        }
    );
  }
  _questionhandler(ShuffledAnswers, Answers, i){
    setState(() {
      state = QuestionState.evaluating;
    });
    bool correct = ShuffledAnswers[i] == Answers[0];
    // print("${_json.correctanswer(this.chapter,this.subchapter[this.subchapterkey],this.question[this.questionkey])}");
    questreslist[subchapterkey].add(correct);

    for(int i = 0; i < ShuffledAnswers.length; i++){
      if(ShuffledAnswers[i] == Answers[0]){
        setState(() {
          highlighting = i;
        });
        break;
      };
    }
    if(correct){
      _overlay(false);
    }
    else{
      _overlay(true);
    }
  }
  _overlay(bool wrong) {

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
                      color: wrong ? Colors.red.shade200: Colors.green.shade200,
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
                      autofocus: false,
                      style: buttonstyle(wrong ? Colors.redAccent : Colors.green),
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
    overlayState!.insert(overlayEntry!);
  }
  _nextquest(){
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

}

orderlist(var elements, bool random){
  int i = 0; List<int> orderlist = List.generate((elements),(generator) {i++; return i - 1;});

  if(!random) return orderlist;
  else orderlist.shuffle(); return orderlist;
}


List<WidgetSpan> parseTextWithMath(String input, TextStyle Textstyle) {
  List<WidgetSpan> widgets = [];
  List<String> parts = input.split('\$');

  for (int i = 0; i < parts.length; i++) {
    if (i % 2 == 0) {
      widgets.add(WidgetSpan(
        child: Text(parts[i], style: Textstyle,),
        alignment: PlaceholderAlignment.middle,
      ));
    } else {
      widgets.add(WidgetSpan(
        child: Math.tex(parts[i], textStyle: Textstyle),
        alignment: PlaceholderAlignment.middle,
      ));
    }
  }

  return widgets;
}