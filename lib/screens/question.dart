import 'package:fuenfzigohm/constants.dart';
import 'package:fuenfzigohm/helpers/question_controller.dart';
import 'package:fuenfzigohm/screens/practise/completeLesson.dart';
import 'package:fuenfzigohm/screens/formelsammlung.dart';
import 'package:fuenfzigohm/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pdfx/pdfx.dart';
import 'package:provider/provider.dart';

enum QuestionState{
  answering, 
  evaluating
}

class Question extends StatefulWidget {
  
  List<int> subchapter;
  int chapter;
  BuildContext context;

  Question(this.context, this.subchapter,this.chapter);

  @override
  createState() => _Questionstate();
}
class _Questionstate extends State<Question> with TickerProviderStateMixin {

  late PdfController pdfController;
  late int questionradio;

  QuestionState status = QuestionState.answering;

  int highlighting = -1;
  
  bool correct = false;
  OverlayEntry? overlayEntry;
  late QuestionController questionManager; 

  _Questionstate();

  @override
  initState() {
    questionManager = this.context.read<QuestionController>();
    questionManager.initialize(widget.context, PractiseTypes.subchapter, widget.chapter, widget.subchapter[0]);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    QuestionElement questionContent = questionManager!.getCurrentQuestion();
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
            Text(
              "Frage "
                  + "${questionContent.number}",
            ),
            Row(
              children: [
                IconButton(icon: Icon(Icons.book), onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Formularpage(1),
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
                          "${questionContent.question}",
                          TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 22
                          ),
                        )
                      ),
                    ),
                  ),
                ),
                questionContent.imageType == ImageType.headerImage 
                ? questionImage(context, questionContent.headerImage!)
                : SizedBox(),
                Divider(height: std_padding * 2,),
                questionContent.imageType == ImageType.imageAnswers 
                ? radioSvgListBuilder(questionContent)
                : radioTextListBuilder(questionContent),
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
                    if(status == QuestionState.answering && questionradio != null){
                      _questionhandler(questionradio, questionContent);
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

  InteractiveViewer questionImage(BuildContext context, String url) {
    List<String> illegalImages = ["BE207_q", "NF106_q", "BE209_q", "NF104_q", "NF102_q", "NF105_q", "BE208_q", "NE209_q", "NG302_q", "NF103_q", "NF101_q"];
    Widget image;
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
          child: Image.asset("assets/svgs/$url.png")
          ),
      );
    } else {
      image = SvgPicture.asset(
        "assets/svgs/$url.svg",
        colorFilter: colorFilter,        
        );
    };
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(20.0),
      maxScale: 1.6,
      panEnabled: false,
      child: image,
    );
  }
ListView radioSvgListBuilder(QuestionElement questionContent) {
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
                if(status == QuestionState.answering){
                  setState(() {
                    questionradio = i;
                  });
                }
              },
              title: questionImage(context, questionContent.answers[i].element),
            ),
          );
        }
    );
  }
  
  ListView radioTextListBuilder(QuestionElement questionContent) {
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
                      if(status == QuestionState.answering){
                        setState(() {
                          questionradio = i;
                        });
                      }
                    },
                    title: RichText(
                      textAlign: TextAlign.left,
                      text: TextSpan(
                        children: parseTextWithMath(
                          "${
                            questionContent.answers.firstWhere((AnswerElement answer) => answer.shuffledIndex == i).element
                            }",
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
  _questionhandler(i, QuestionElement questionContent){
    setState(() {
      status = QuestionState.evaluating;
    });
    bool correct = questionContent.answers.firstWhere((AnswerElement answer) => answer.shuffledIndex == i).correct;

    questionManager.saveCurrentResult(correct);
    
    
    setState(() {
      highlighting = questionContent.answers[0].shuffledIndex;
    });
    
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
                  padding: EdgeInsets.only(bottom: 10, left: 8,),
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
      questionManager.goNextQuestion();
    } catch(NoMoreQuestionsException){
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (con) => Finish(questionManager, widget.context)),
      );
    }
    setState(() {
      questionradio = -1;
      highlighting = -1;
      status = QuestionState.answering;

    });
    
  }

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