import 'package:fuenfzigohm/constants.dart';
import 'package:fuenfzigohm/coustom_libs/json.dart';
import 'package:fuenfzigohm/coustom_libs/questionState.dart';
import 'package:fuenfzigohm/screens/pdfViewer.dart';
import 'package:fuenfzigohm/screens/questionPage/mathParser.dart';
import 'package:fuenfzigohm/screens/questionPage/questionImage.dart';
import 'package:fuenfzigohm/style/style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'overlay.dart';

class Question extends StatefulWidget {

  var subchapter, chapter;
  final BuildContext context;

  Question(this.context, this.subchapter,this.chapter);

  @override
  createState() => _Questionstate(this.context, this.subchapter,this.chapter);
}
class _Questionstate extends State<Question> with TickerProviderStateMixin {

  var pdfController, questionradio, highlighting;

  final context, chapter, subchapter;

  late Json json;

  OverlayEntry? overlayEntry;
  late QuestionManager questionManager;

  _Questionstate(this.context, this.subchapter,this.chapter);

  @override
  initState() {
    questionManager = Provider.of<QuestionManager>(context);
    questionManager.initSubChapter(context, chapter, subchapter);
    questionManager.addListener(_onQuestionManagerChanged);

    super.initState();
  }


  void _onQuestionManagerChanged() {
    if(questionManager.getQuestionState() == QuestionState.evaluating) {
      bool correct = questionManager.getEvaluation();
      if(!correct) setState(() {
        highlighting = questionManager.getCorrectAnswer();
      });
      overlayEntry = overlayQuestion(correct, context, questionManager);
    }else if (questionManager.getQuestionState() == QuestionState.answering){
      setState(() {
        overlayEntry?.remove();
        questionradio = null;
        highlighting = null;
      });
    } else if(questionManager.getQuestionState() == QuestionState.dispose){
      if(overlayEntry != null && overlayEntry!.mounted)
        overlayEntry!.remove();
     return;
    }
  }

  @override
  void dispose() {
    if(overlayEntry != null && overlayEntry!.mounted)
      overlayEntry!.remove();
    questionManager.removeListener(_onQuestionManagerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(10, 0, 0, 0),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Frage "
                  + "${questionManager.getQuestionID()}",
            ),
            Row(
                children: [
                IconButton(icon: Icon(Icons.functions), onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PdfViewer(1, "assets/pdf/Formelsammlung.pdf", "Formelsammlung"),
                    )
                  );
                  },
                ),
                IconButton(icon: Icon(Icons.description), onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PdfViewer(1, "assets/pdf/Anlage_1_AFuV.pdf", "Anlage 1 AFuV"),
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
                Padding(
                  padding: EdgeInsets.only(top: std_padding, left: std_padding, right: std_padding),
                  child: Center(
                    child: RichText(
                      textAlign: TextAlign.left,
                      text: TextSpan(
                        children: parseTextWithMath(
                          "${questionManager.getQuestionQuestion()}",
                          TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 22
                          ),
                        )
                      ),
                    ),
                  ),
                ),
                questionManager.getQuestionImage() != null
                  ? questionImage(context, questionManager.getQuestionImage()!)
                  : SizedBox(),
                Divider(height: std_padding * 2,),
                questionManager.getQuestionImage() != null
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
                    if(questionManager.getQuestionState() == QuestionState.answering
                        && questionradio != null){
                      questionManager.evaluateQuestion(questionradio);
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
                if(questionManager.getQuestionState() == QuestionState.answering){
                  setState(() {
                    questionradio = i;
                  });
                }
              },
              title: questionImage(context, questionManager.getQuestionImage()!),
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
                    fillColor: MaterialStateColor.resolveWith((states) => main_col),                    activeColor: main_col,
                    groupValue: questionradio,
                    value: i,
                    onChanged: (var value) {
                      if(questionManager.getQuestionState() == QuestionState.answering){
                        setState(() {
                          questionradio = i;
                        });
                      }
                    },
                    title: RichText(
                      textAlign: TextAlign.left,
                      text: TextSpan(
                        children: parseTextWithMath(
                          "${questionManager.getQuestionAnswers(i)}",
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
}