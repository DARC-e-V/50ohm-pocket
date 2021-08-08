
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../constants.dart';
import 'chapterpage.dart';
import 'finish.dart';


class Question extends StatefulWidget {

  var subchapter, chapter, json;
  final BuildContext context;

  Question(this.context, this.json, this.subchapter,this.chapter);

  @override
  createState() => _Questionstate(this.context, this.json, this.subchapter,this.chapter);
}
class _Questionstate extends State<Question> with TickerProviderStateMixin {

  var json, answerorder, /* desperate */chapterorder, questionorder;
  var questionkey, subchapterkey = 0;
  final context, chapter;
  List subchapter;
  var questionradio;
  bool correct = false;

  _Questionstate(this.context, this.json, this.subchapter,this.chapter);

  @override
  initState() {
    questionkey = 0;
    subchapterkey = 0;
    setState(() {
      print("$chapter and $subchapter");

      if(subchapter.length == 0) questionorder = orderlist(json.questonlylistleng(chapter), true);
      else questionorder = orderlist(json.subchaptersize(chapter,subchapter[subchapterkey]), true);

      print("questionorder $questionorder");
      // Todo: dynamic not 4 with json.answercount Note also needed when rebuilding window
      chapterorder = subchapter;
      print("$chapterorder");

      answerorder = orderlist(4,true);
    });
    // print("chapterorder" + "$chapterorder");
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
              //LinearProgressIndicator(value: json.procentofchapter(answerorder, questionkey),),
              Padding(
                padding: EdgeInsets.only(top: std_padding, left: std_padding, right: std_padding),
                child: Center(
                  child: HtmlWidget(
                    "${json.questionname(chapter,subchapter.length == 0 ? Null : chapterorder[subchapterkey], questionorder[questionkey])}",
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
                                "${json.answer(chapter,subchapter.length == 0 ? Null : chapterorder[subchapterkey],questionorder[questionkey],answerorder[i])[0]}",
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
              padding: EdgeInsets.only(bottom: 10, left: 8, right: 8),
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
    var correct =
      (json.answer(chapter, subchapter.length == 0 ? Null : chapterorder[subchapterkey], questionorder[questionkey], answerorder[questionradio]))[1];
    // print("${_json.correctanswer(this.chapter,this.subchapter[this.subchapterkey],this.question[this.questionkey])}");
    if(correct){
      _overlay(false);
    }
    else{
      print("subchapter $subchapter , chapter $chapter , question $questionorder[this.questionkey]");
      _overlay(true, correctanser : json.correctanswer(chapter, subchapter.length == 0 ? Null : chapterorder[subchapterkey], questionorder[questionkey]));
    }
  }
  _overlay(bool wrong, {var correctanser = true}) {

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
                              ? Padding(
                                padding: const EdgeInsets.only(left: 8, right: 8),
                                child: SizedBox(
                                width: 700,
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
                          ),
                              )
                              : Text(""),
                          //Text(wrong ? "Leider falsch" : "Super richtig"),
                          Padding(
                            padding: EdgeInsets.only(left: 8, right: 8),
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
      this.questionorder[this.questionkey + 1];
      this.questionradio = null;
      setState(() {
        questionradio = null;
        questionkey += 1;
        answerorder = orderlist(4,true);
      });
    }catch(e){
      try{
          print("\n Subchapter over");
          this.chapterorder[this.subchapterkey];
          setState(() {
            questionradio = null;
            subchapterkey += 1;
            questionorder = buildquestionlist(chapter, subchapter[subchapterkey], json, true);
            questionkey = 0;
          });
      }catch(e){
        print("\n Failed with $e");
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Finish(chapter,0,0,0)),
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
