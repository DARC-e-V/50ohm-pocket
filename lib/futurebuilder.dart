import 'dart:async' show Future;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'chapter.dart';
import 'constants.dart';

futurebuilder(var context) => FutureBuilder(
  future: loadAsset(),
  builder: (context, snapshot){
    if (snapshot.hasData) {
      var build_info = jsonprocess(snapshot.data);
      return selectlesson(build_info, context);
    }else if(snapshot.hasError){
      return
        Row(
            children: [
              Icon(
                Icons.warning,
                color: Colors.red,
                size: 40,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child:
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: "Die Fragen konnten nicht geladen werden. ",style: TextStyle(fontWeight: FontWeight.bold),),
                        TextSpan(text: "Bitte wende dich an $admin_mail für weitere Hilfe.")
                      ],
                    ),
                  ),
                ),
              ),
            ]
        );
    } else{
      return Padding(padding: EdgeInsets.all(std_padding), child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          Text("Inhalte werden geladen ..."),

        ],
      ),);
    }
  },
);

Map<String, dynamic> jsonprocess(var data) {
  Map<String, dynamic> parsedjson = jsonDecode(data);
  return parsedjson;
}

Future loadAsset() async {
  return rootBundle.loadString('assets/DL_Technik_Klasse_E_2007/questions.json');
}
