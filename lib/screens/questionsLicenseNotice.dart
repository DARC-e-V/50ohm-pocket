import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class QuestionsLicensePage extends StatelessWidget {
  _launchURL(String url) async {
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
        title: Text('Amateurfunkprüfungsbescheinigungen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prüfungsfragen zum Erwerb von Amateurfunkprüfungsbescheinigungen,',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Bundesnetzagentur, 2. Auflage, Dezember 2023,',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            GestureDetector(
              onTap: () => _launchURL('https://www.bundesnetzagentur.de/amateurfunk'),
              child: Text(
                'www.bundesnetzagentur.de/amateurfunk',
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Datenlizenz Deutschland – Namensnennung – Version 2.0',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            GestureDetector(
              onTap: () => _launchURL('https://www.govdata.de/dl-de/by-2-0'),
              child: Text(
                'www.govdata.de/dl-de/by-2-0',
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}