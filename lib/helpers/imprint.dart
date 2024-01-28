import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ImprintPage extends StatefulWidget {
  @override
  _ImprintPageState createState() => _ImprintPageState();
}

class _ImprintPageState extends State<ImprintPage> {
  final String url = "https://www.darc.de/impressum/";

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
        title: Text('Impressum'),
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
