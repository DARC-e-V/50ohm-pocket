
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:confetti/confetti.dart';

import '../../constants.dart';
import '../../coustom_libs/json.dart';

// please let me know weather there is a bloat free variant of this

class Question extends StatefulWidget {
  var subchapter, chapter, questionnum;
  final BuildContext context;
  Question(this.context, this.subchapter,this.chapter,this.questionnum);
  @override
  createState() => _Questionstate(this.context, this.subchapter,this.chapter,this.questionnum);
}
class _Questionstate extends State<Question> with TickerProviderStateMixin {

  var _json, answerorder, chapterorder;
  var questionkey, subchapterkey = 0;
  final context, chapter;
  List subchapter, question;
  var questionradio;
  bool correct = false;


  _Questionstate(this.context,this.subchapter,this.chapter,this.question);
  @override
  initState() {
    questionkey = 0;
    subchapterkey = 0;
    print("subchapterlistlenghth " + "${subchapter.length}" + "${subchapter}");
    setState(() {
      // To do: dynamic not 4 lol
      chapterorder = subchapter.length == 1 ? subchapter : orderlist(subchapter.length ,true);
      answerorder = orderlist(4,true);
      _json = Json(JsonWidget.of(context).json);
    });
    print("chapterorder" + "$chapterorder");
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    //!!change to false for non random answers
    return Scaffold(
      appBar: AppBar(
        title: Text("Afutrainer"),
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              LinearProgressIndicator(value: _json.procentofchapter(answerorder, questionkey),),
              Padding(
                padding: EdgeInsets.only(top: std_padding, left: std_padding, right: std_padding),
                child: Center(
                  child: HtmlWidget(
                    "${_json.questionname(chapter,chapterorder[subchapterkey],question[questionkey])}",
                    textStyle: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 22
                    ),
                  ),
                ),
              ),
              Divider(height: std_padding * 2,),
              ListView.builder(
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
                            title: HtmlWidget(
                                "${_json.answer(chapter,chapterorder[subchapterkey],question[questionkey],answerorder[i])[0]}",
                                textStyle: TextStyle(
                                  fontSize: 19
                                ),
                            ),
                          ),
                        ]
                    );
                  }
              ),
              SizedBox(height: 60),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
              child: ElevatedButton(

                autofocus: false,
                style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all<Size>(Size(700,60),),
                    textStyle: MaterialStateProperty.all<TextStyle>(
                      TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 25,
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blueAccent),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7.0),
                        )
                    )
                ),

                onPressed: questionradio == null ? null :  () =>  _questionhandler(),
                child: Text("Überprüfen"),
              ),
            ),
          ),
        ],
      )
    );
  }
  _questionhandler(){
    var correct = (_json.answer(this.chapter,this.subchapter[this.subchapterkey],this.question[this.questionkey],this.answerorder[this.questionradio]))[1];
    print("${_json.correctanswer(this.chapter,this.subchapter[this.subchapterkey],this.question[this.questionkey])}");
    if(correct){
      _overlay(false);
    }
    else{
      _overlay(true, correctanser : _json.correctanswer(this.chapter,this.subchapter[this.subchapterkey],this.question[this.questionkey]));
    }
  }
  _overlay(bool wrong, {var correctanser = true}) {
    late AnimationController _animationcontroller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    late Animation<double> _animation = CurvedAnimation(
        parent: _animationcontroller,
        curve: Curves.easeIn,
    );

    OverlayState? overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
        builder: (buildcontext){
          return  Container(
              color: wrong ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Material(
                      child: Stack(
                        alignment: AlignmentDirectional.bottomCenter,
                        children: [
                          wrong
                              ? SizedBox(
                              width: 900,
                              //height: MediaQuery.of(context).size.height / 2,
                              child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.red.shade200,
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 30, bottom: 80, right: 24, left: 24),
                                      child: HtmlWidget(
                                          "$correctanser",
                                          textStyle: TextStyle(
                                            backgroundColor: Colors.red.shade200,
                                            color: Colors.white,
                                            fontSize: 30
                                          ),

                                        ),
                                    ),

                                  )
                              )
                          )
                              : Text(""),
                          //Text(wrong ? "Leider falsch" : "Super richtig"),
                          Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: ElevatedButton(
                              autofocus: false,
                              style: ButtonStyle(
                                  fixedSize: MaterialStateProperty.all<Size>(Size(700,60),),
                                  textStyle: MaterialStateProperty.all<TextStyle>(
                                    TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 25,
                                    ),
                                  ),
                                  backgroundColor: MaterialStateProperty.all<Color>(wrong ? Colors.redAccent : Colors.green),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(7.0),
                                      )
                                  )
                              ),
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
                )
          );
      },
    );
    overlayState!.insert(overlayEntry);
  }
  _nextquest(){
    try{
      this.question[questionkey + 1];
      setState(() {
        questionradio = null;
        this.questionkey += 1;
        // To do: dynamic not 4 lol
        this.answerorder = orderlist(4,true);
      });
      ///Code that's executed when answer is correct
      this.questionradio = null;
    }catch(e){
      try{
        this.subchapterkey += 1;
      }catch(e){}
      Navigator.of(context).pop();
/*
      OverlayState? overlayState = Overlay.of(context);
      late OverlayEntry overlayEntry;

      overlayEntry = OverlayEntry(
          builder: (BuildContext context) => ConfettiWidget(
            confettiController: ConfettiController(duration: const Duration(seconds: 13)),
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: true,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple
            ],
            emissionFrequency: 0.6,
            gravity: 0.1,
          )
      );
      overlayState!.insert(overlayEntry);
      ConfettiWidget(
        confettiController: ConfettiController(duration: const Duration(seconds: 3)),
        child: Text("PARTY"),

      );*/
    }
  }

}

orderlist(var elements, bool random){
  int i = 0; List<int> orderlist = List.generate((elements),(generator) {i++; return i - 1;});

  if(!random) return orderlist;
  else orderlist.shuffle(); return orderlist;
}
