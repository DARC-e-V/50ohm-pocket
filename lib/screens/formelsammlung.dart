import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class Formularpage extends StatelessWidget{
  final start_at;
  Formularpage(this.start_at);

  @override
  Widget build(BuildContext context) {
  final pdfController = PdfControllerPinch(
    document: PdfDocument.openAsset('assets/pdf/Formelsammlung.pdf'),
  );

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: (){
            Navigator.of(context).pop();
          },
        ),
        title: Text("Formelsammlung"),
      ),
      body: PdfViewPinch(
        controller: pdfController,
      ),
    );
  }
}
