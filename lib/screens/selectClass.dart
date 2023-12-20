


import 'package:amateurfunktrainer/coustom_libs/database.dart';
import 'package:flutter/material.dart';

class selectClass extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return 
      Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Was möchtest du lernen?", ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                InkWell(
                  onTap: (){
                    handleStart([2], context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xffFE756C),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Upgrade von N auf E", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Du hast schon deine N Zulassung? Super! Starte heute mit deinen Vorbereitungen auf die Klasse E.",
                                    style: TextStyle(fontSize: 17),
                                    )),
                                Icon(Icons.arrow_forward_ios)
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: (){
                    handleStart([3], context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xff3BB583),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Upgrade von E auf A", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Du hast deine E Zulassung? Super! Starte heute mit deinen Vorbereitungen auf die Klasse E.",
                                    style: TextStyle(fontSize: 17),
                                    )),
                                Icon(Icons.arrow_forward_ios)
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: (){
                    handleStart([2, 3], context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xff47ABE8),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Upgrade von N auf A", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Du hast deine N Zulassung? Super! Starte heute mit deinen Vorbereitungen auf die Klasse A.",
                                    style: TextStyle(fontSize: 17),
                                    )),
                                Icon(Icons.arrow_forward_ios)
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                ],
            ),
          ),
        ),
      );
  }

void handleStart(List<int> klasse, BuildContext context){
  DatabaseWidget.of(context).settings_database.put("welcomePage", true);
  DatabaseWidget.of(context).settings_database.put("Klasse", klasse);
  Navigator.pushNamedAndRemoveUntil(context, "/learn", (r) => false);
}


}