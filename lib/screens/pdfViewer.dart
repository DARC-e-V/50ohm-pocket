import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class PdfViewer extends StatelessWidget{
  final start_at;
  final String path;
  final String title;
  PdfViewer(this.start_at, this.path, this.title);

  @override
  Widget build(BuildContext context) {
  final pdfController = PdfControllerPinch(
    document: PdfDocument.openAsset(path),
  );

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: (){
            Navigator.of(context).pop();
          },
        ),
        title: Text(title),
      ),
      body: PdfViewPinch(
        controller: pdfController,
      ),
    );
  }
}
