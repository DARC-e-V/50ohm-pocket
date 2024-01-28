import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MailPage extends StatefulWidget {
  @override
  _MailPageState createState() => _MailPageState();
}

class _MailPageState extends State<MailPage> {
  final String url = "mailto:app@darc.de?subject=App%20DARC&body=Hallo%20ehrenamtliches%20App-Team,%0D%0A%0D%0A";

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
        title: Text('E-Mail'),
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
