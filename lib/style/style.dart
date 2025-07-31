import 'package:flutter/material.dart';

import '../constants.dart';

// TODO: Set up all colors, warning and success
lightmode() => ThemeData.from(
      colorScheme: ColorScheme.light(primary: Color(0xFF01ACF1)),
    );

// TODO: Set up all colors, warning and success
darkmode() => ThemeData.from(
      colorScheme: ColorScheme.dark(primary: Color(0xFF01ACF1)),
    );

// TODO: Remove this, discuss general button style, derivates, etc.
buttonstyle(Color color) => ButtonStyle(
      fixedSize: MaterialStateProperty.all<Size>(
        Size(700, 60),
      ),
      textStyle: MaterialStateProperty.all<TextStyle>(
        TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),
      backgroundColor: MaterialStateProperty.all<Color>(color),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7.0),
        ),
      ),
    );
