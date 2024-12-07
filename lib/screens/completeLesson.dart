import 'package:fuenfzigohm/coustom_libs/questionState.dart';
import 'package:fuenfzigohm/style/style.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class Finish extends StatefulWidget{
  List<QuestionEvaluation> questionEvaluation;

  Finish(this.questionEvaluation);

  @override
  State<StatefulWidget> createState() =>
     _finishstate(this.questionEvaluation);

}

class _finishstate extends State<Finish>{
  List<QuestionEvaluation> questionEvaluation;

  _finishstate(this.questionEvaluation);
  
  @override
  Widget build(BuildContext buildcontext) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 18.0, left: 18),
                child: Text("Du hast die Lektion geschafft!",
                 style: TextStyle(
                   fontSize: 30,
                   fontWeight: FontWeight.bold,
                   ),),
              ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: AspectRatio(
                  aspectRatio: 0.8,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: progress(),
                          color: Colors.green,
                          title: "richtig",
                        ),
                        PieChartSectionData(
                          value: 100.0 - progress(),
                          color: Colors.red,
                          title: "falsch",
                        ),
                      ]
                    ),
                    swapAnimationDuration: Duration(milliseconds: 1500), // Optional
                    swapAnimationCurve: Curves.linear, 
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(left: 8, right: 8, bottom: 10),
                  child: ElevatedButton(
                    style: buttonstyle(Colors.lightGreenAccent),
                    child: Text("Abschließen"),
                    onPressed: (){
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(true);
                      },
                    ),
                ),
              )
            ],
            ),
        ),
      )
    );
  }
  progress(){
    int x = 0;
    int y = 0;

    for(QuestionEvaluation qe in questionEvaluation){
      if(qe.correct){
        x++;
      }
      y++;
    }
    return (x / y) * 100;
  }
}