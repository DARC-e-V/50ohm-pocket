import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class Formularpage extends StatelessWidget{
  final start_at;
  Formularpage(this.start_at);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Formelsammlung"),
      ),
      body: PDFView(
        filePath: "assets/pdf/Formelsammlung.pdf",
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: false,
        pageFling: false,
      ),
    );
  }
}
