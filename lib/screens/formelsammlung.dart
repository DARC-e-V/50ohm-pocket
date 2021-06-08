import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter/services.dart';

class Formularypage extends StatefulWidget{
  @override
  _formularystate createState() => _formularystate();
}

class _formularystate extends State<Formularypage> {
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
    PDFDocument doc = await PDFDocument.fromAsset('assets/DL_Technik_Klasse_E_2007/Formelsammlung.pdf');
    return doc;
  }

}
