import 'package:amateurfunktrainer/coustom_libs/json.dart';
import 'package:flutter/material.dart';

import '../screens/learning/chapterpage.dart';
import '../constants.dart';

futurebuilder(var context, var path) {
  return FutureBuilder(
      future: Json(null).load(path),
      builder: (context, snapshot){
        if (snapshot.hasData) {
          return JsonWidget(selectlesson(snapshot.data, context),(snapshot.data as Map<String, dynamic>));
        }else if(snapshot.hasError){
          return Text("Konnte die Fragen nicht laden");
        } else{
          return Padding(padding: EdgeInsets.all(std_padding), child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              Text("Inhalte werden geladen ..."),
              ],
          ),
          );
        }
        },
  );
}
