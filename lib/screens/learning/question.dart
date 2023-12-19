
import 'package:amateurfunktrainer/coustom_libs/json.dart';
import 'package:amateurfunktrainer/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_svg/flutter_svg.dart';


import '../../constants.dart';
import '../formelsammlung.dart';
import 'chapterpage.dart';
import 'finish.dart';


class Question extends StatefulWidget {

  var subchapter, chapter;
  final BuildContext context;

  Question(this.context, this.subchapter,this.chapter);

  @override
  createState() => _Questionstate(this.context, this.subchapter,this.chapter);
}
class _Questionstate extends State<Question> with TickerProviderStateMixin {

  var answerorder, questionorder, questreslist, pdfController, questionradio;
  
  
  late int questionkey, subchapterkey;
  late List<String> ShuffledAnswers, Answers;
  
  final List subchapter;
  final context, chapter;

  late Json json;
  bool imageQuestion = false; 
  bool correct = false;

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

      answerorder = orderlist(4,true);

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

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(10, 0, 0, 0),
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Frage "
                  + "${json.questionid(chapter,subchapter.length == 0 ? Null : subchapter[subchapterkey], questionorder[questionkey])}",
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
                SizedBox(width: 5,),
                IconButton(icon: Icon(Icons.flag), onPressed: () {

                },),
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
                json.questionimage(chapter,subchapter.length == 0 ? Null : subchapter[subchapterkey], questionorder[questionkey]) != null ?
                SvgPicture.asset("assets/svgs/${json.questionimage(chapter,subchapter.length == 0 ? Null : subchapter[subchapterkey], questionorder[questionkey])!}.svg"): SizedBox(),
                Divider(height: std_padding * 2,),
                imageQuestion 
                ? radioSvgListBuilder() 
                : radioTextListBuilder(),
                SizedBox(height: 60),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 10, left: 8, right: 8),
                child: ElevatedButton(
                  autofocus: false,
                  style: buttonstyle(Colors.blueAccent),
                  onPressed: questionradio == null ? null :  () =>  _questionhandler(ShuffledAnswers, Answers, questionradio),
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
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        addAutomaticKeepAlives: true,
        shrinkWrap: true,
        itemCount: answerorder.length,
        itemBuilder: (context, i){
          return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RadioListTile(
                  groupValue: questionradio,
                  value: i,
                  onChanged: (var value) {setState(() {questionradio = i;});},
                  title: SvgPicture.asset("assets/svgs/${Answers[i]}.svg"),
                ),
              ]
          );
        }
    );
  }
  
  ListView radioTextListBuilder() {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        addAutomaticKeepAlives: true,
        shrinkWrap: true,
        itemCount: answerorder.length,
        itemBuilder: (context, i){
          return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RadioListTile(
                  activeColor: Colors.blue,
                  groupValue: questionradio,
                  value: i,
                  onChanged: (var value) {setState(() {questionradio = i;});},
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
              ]
          );
        }
    );
  }
  _questionhandler(ShuffledAnswers, Answers, i){

    bool correct = ShuffledAnswers[i] == Answers[0];
    // print("${_json.correctanswer(this.chapter,this.subchapter[this.subchapterkey],this.question[this.questionkey])}");
    questreslist[subchapterkey].add(correct);
    if(correct){
      _overlay(false);
    }
    else{
      _overlay(true, correctAnswer : Answers[0]);
    }
  }
  _overlay(bool wrong, {var correctAnswer = true}) {

    OverlayState? overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
        builder: (buildcontext){
          return  Container(
              color: wrong ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.1),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Material(
                        child: Stack(
                          alignment: AlignmentDirectional.bottomCenter,
                          children: [
                            wrong
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 0, right: 0),
                                    child: SizedBox(
                                    width: 700,
                                    //height: MediaQuery.of(context).size.height / 2,
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade200,
                                        ),
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 30, bottom: 80, right: 0, left: 0),
                                            child: Text(
                                                "$correctAnswer",
                                                style: TextStyle(
                                                  backgroundColor: Colors.red.shade200,
                                                  color: Colors.white,
                                                  fontSize: 30
                                                ),
                            
                                              ),
                                          ),
                            
                                        )
                                    )
                              ),
                                )
                                : Text(""),
                            Padding(
                              padding: EdgeInsets.only(left: 8, right: 8,),
                              child: ElevatedButton(
                                autofocus: false,
                                style: buttonstyle(wrong ? Colors.redAccent : Colors.green),
                                onPressed: (){
                                  overlayEntry.remove();
                                  _nextquest();
                                },
                                child: Text("Weiter"),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10,)
                    ],
                  ),
                )
          );
      },
    );
    overlayState!.insert(overlayEntry);
  }
  _nextquest(){
    try{
      this.questionorder[this.questionkey + 1];
      this.questionradio = null;
      setState(() {
        questionradio = null;
        questionkey += 1;
        answerorder = orderlist(4,true);
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
        Navigator.of(context).pop();
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
        child: Math.tex(parts[i], textStyle: Textstyle, settings: TexParserSettings(maxExpand: 100 )),
        alignment: PlaceholderAlignment.middle,
      ));
    }
  }

  return widgets;
}