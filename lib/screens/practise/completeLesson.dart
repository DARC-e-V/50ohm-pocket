import 'package:fuenfzigohm/coustom_libs/database.dart';
import 'package:fuenfzigohm/coustom_libs/json.dart';
import 'package:fuenfzigohm/helpers/question_controller.dart';
import 'package:fuenfzigohm/style/style.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class Finish extends StatefulWidget{
  QuestionController questionController;
  BuildContext context;

  Finish( this.questionController, this.context);

  @override
  State<StatefulWidget> createState() =>
     _finishstate();

}

class _finishstate extends State<Finish>{

  _finishstate( );
  
  @override
  Widget build(BuildContext buildcontext) {
    Databaseobj(context).write(widget.questionController);
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height - 240,
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
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
                      swapAnimationDuration: Duration(milliseconds: 15000), // Optional
                      swapAnimationCurve: Curves.linear, 
                    ),
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
    for(var item in this.result){
      item = item.map((x) => x ? 1 : 0).toList();
      x += (item.fold(0, (var i, element) => element + i) as int);
      y = y + (item.length as int);
    }
    return (x / y) * 100;
  }
}