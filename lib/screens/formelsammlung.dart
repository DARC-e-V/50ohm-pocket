import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';

class Formularpage extends StatefulWidget{
  @override
  _formularstate createState() => _formularstate();
}

class _formularstate extends State<Formularpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Formelsammlung"),
      ),
      body: FutureBuilder(
        future: _loadpdf(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if(snapshot.hasData){
            return Text("$snapshot");
        }
          if(snapshot.hasError){
            print("$snapshot");
            return Text("Fehler" + "$snapshot");
          }
          return Text("läd");
          },
      ),
    );
  }

  _loadpdf() async{
    PDFDocument doc = await PDFDocument.fromAsset('assets/Formelsammlung.pdf');
    return doc;
  }

}
