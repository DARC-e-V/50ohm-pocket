import 'package:amateurfunktrainer/coustom_libs/database.dart';
import 'package:amateurfunktrainer/coustom_libs/json.dart';
import 'package:amateurfunktrainer/style/style.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class Finish extends StatefulWidget{
  var subchapter, chapter, result, context;
  Finish( this.chapter, this.subchapter, this.result, this.context);

  @override
  State<StatefulWidget> createState() =>
     _finishstate(subchapter, chapter, result, context);

}

class _finishstate extends State<Finish>{
  var subchapter, chapter, result, context;

  _finishstate( this.subchapter, this.chapter, this.result, this.context);
  
  @override
  Widget build(BuildContext buildcontext) {
    Databaseobj(context).write(JsonWidget.of(context).mainchapter, chapter, subchapter, result);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Auswertung"),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text("Du hast die Lektion geschafft!",
               style: TextStyle(
                 fontSize: 30,
                 fontWeight: FontWeight.bold,
                 ),),
            ),
            Expanded(
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