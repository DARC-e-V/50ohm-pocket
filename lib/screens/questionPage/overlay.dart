import 'package:flutter/material.dart';
import 'package:fuenfzigohm/coustom_libs/questionState.dart';
import 'package:fuenfzigohm/screens/questionPage/mathParser.dart';
import 'package:fuenfzigohm/style/style.dart';

overlayQuestion(
    bool correct,
    BuildContext context,
    QuestionManager questionManager,
    OverlayEntry overlayEntry
    ) {

  OverlayState? overlayState = Overlay.of(context);
  // give a short and motivating statement to motivate the user not to exagurating
  List<String> motivational_message = [
    "Gut gemacht!",
    "Weiter so!",
    "Genau!",
    "Richtig!"
  ];
  List<String> motivational_message_false = [
    "Schade!",
    "Das war leider falsch!",
    "Die Antwort ist falsch!",
    "Das war nicht richtig!"
  ];
  // select one random message and give back a string
  if(correct){
    motivational_message.shuffle();
  }else{
    motivational_message_false.shuffle();
  }
  overlayEntry = OverlayEntry(
    builder: (buildcontext){
      return  Container(
          child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: correct ? Colors.green.shade200 : Colors.red.shade200,
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 90, right: 20, left: 20),
                      child:
                      RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                            children: parseTextWithMath(
                              correct ? motivational_message[0] : motivational_message_false[0],
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
                    style: buttonstyle(correct ?  Colors.green : Colors.redAccent),
                    onPressed: (){
                      questionManager.nextQuestion();
                      overlayEntry.remove();
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
  overlayState.insert(overlayEntry);
}
