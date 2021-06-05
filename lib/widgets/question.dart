
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../constants.dart';
import '../json.dart';

void pushquestion(final title, BuildContext context, var data, var chapter, var subchapter) {
  var menuq = Chaptermenu(data);
  var qdata = menuq.question(chapter,subchapter);
  var questiontitle = qdata["@id"];
  print(qdata);
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (BuildContext context){
      return Scaffold(
          appBar: AppBar(
            title: Text(title), backgroundColor: main_col,
          ),
          body: ListView(
            children: [
              Padding(padding: EdgeInsets.only(top: std_padding, left: std_padding, right: std_padding), child: HtmlWidget(qdata["textquestion"],textStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 20
              ),),),
              Divider(height: std_padding * 2,),
              ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  addAutomaticKeepAlives: true,
                  shrinkWrap: true,
                  itemCount: qdata["textanswer"].length,
                  itemBuilder: (context, i){
                    print(i);

                    return ListTile(
                      title: HtmlWidget(i == 0 ? qdata["textanswer"][i]["text"] : qdata["textanswer"][i]),
                      leading : Radio(
                        value: "GDEZ", onChanged: (String? value) {  }, groupValue: '',
                      ),
                    );
                  }),
              ElevatedButton(onPressed: () {}, child: Text("Überprüfen"),
              )],
          )
      );
    }),
  );
}
