import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final String error;
  final String stackTrace;

  ErrorPage(this.error, this.stackTrace);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('An error has occurred: $error'),
            Text('Stack trace: $stackTrace'),
          ],
        ),
      ),
    );
  }
}

