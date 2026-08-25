import 'package:flutter/material.dart';

// TODO: Set up all colors, warning and success
lightmode() => ThemeData.from(
      colorScheme: ColorScheme.light(primary: Color(0xFF01ACF1)),
    ).copyWith(
      appBarTheme: const AppBarTheme(
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        linearTrackColor: Color(0xFFE0E0E0),
      ),
      popupMenuTheme: const PopupMenuThemeData(
        surfaceTintColor: Colors.transparent,
      ),
    );

// TODO: Set up all colors, warning and success
darkmode() => ThemeData.from(
      colorScheme: ColorScheme.dark(primary: Color(0xFF01ACF1)),
    ).copyWith(
      appBarTheme: const AppBarTheme(
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        linearTrackColor: Color(0xFF49454F),
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: Color(0xFF29262F),
        surfaceTintColor: Colors.transparent,
      ),
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
