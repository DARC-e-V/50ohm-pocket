import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter/material.dart';

List<WidgetSpan> parseTextWithMath(String input, TextStyle Textstyle) {
  List<WidgetSpan> widgets = [];
  List<String> parts = input.split('\$');

  for (int i = 0; i < parts.length; i++) {
    if (i % 2 == 0) {
      widgets.add(WidgetSpan(
        child: Text(parts[i], style: Textstyle,),
        alignment: PlaceholderAlignment.middle,
      ));
    } else {
      widgets.add(WidgetSpan(
        child: Math.tex(parts[i], textStyle: Textstyle),
        alignment: PlaceholderAlignment.middle,
      ));
    }
  }

  return widgets;
}