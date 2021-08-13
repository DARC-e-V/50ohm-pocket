import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

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
      body: Container(
        child: SfPdfViewer.asset("assets/Formelsammlung.pdf"),
    ));
  }
}
