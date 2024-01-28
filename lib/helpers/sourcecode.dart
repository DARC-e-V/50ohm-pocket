import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SourceCodePage extends StatefulWidget {
  @override
  _SourceCodePageState createState() => _SourceCodePageState();
}

class _SourceCodePageState extends State<SourceCodePage> {
  final String url = "https://github.com/DARC-e-V/50ohm-pocket";

  @override
  void initState() {
    super.initState();
    _launchURL();
  }

  Future<void> _launchURL() async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quellcode'),
        leading: BackButton(
          onPressed: (){
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed("/aboutApp");
          },
        ),
      ),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
