import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class Formularpage extends StatelessWidget{
  final start_at;
  Formularpage(this.start_at);

  @override
  Widget build(BuildContext context) {
    final pdfController = PdfController(
      document: PdfDocument.openAsset('assets/pdf/Formelsammlung.pdf'),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("Formelsammlung"),
      ),
      body: PdfView(
        controller: pdfController,
      )
    );
  }
}
