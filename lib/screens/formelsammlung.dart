import 'package:amateurfunktrainer/coustom_libs/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:native_pdf_view/native_pdf_view.dart';

class Formularpage extends StatefulWidget{
  var start_at;
  Formularpage(this.start_at);
  @override
  _formularstate createState() => _formularstate(start_at);
}

class _formularstate extends State<Formularpage> {
  var settings, start_at;
  int _allPagesCount = 2;
  late PdfController pdfController;

  _formularstate(this.start_at);

  @override
  void initState() {
    pdfController = PdfController(
      document: PdfDocument.openAsset('assets/Formelsammlung.pdf'),
      initialPage: 1,
    );
    super.initState();
  }
  @override
  void dispose() {
    pdfController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Formelsammlung"),
      ),
      body:
          Stack(

            children: [

              PdfView(
                documentLoader: Center(child: CircularProgressIndicator()),
                pageLoader: Center(child: CircularProgressIndicator()),
                onDocumentLoaded: (document) {
                  setState(() {
                    _allPagesCount = document.pagesCount;
                  });
                },
                controller: pdfController,
                pageSnapping: false,
              ),

            ]
          ),
        );
  }
}
