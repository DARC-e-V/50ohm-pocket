import 'package:flutter/material.dart';

import '../constants.dart';


lightmode() => ThemeData(
                primaryColorLight: Color(0xFFE1E6FF),
                brightness: Brightness.light,
                primarySwatch: Colors.indigo,
                textTheme: TextTheme(
                    headline5: TextStyle(color: Colors.white, fontWeight: FontWeight.w500,)
                )
            );

darkmode() => ThemeData(
                primaryColorDark: Color(0xFF1C1F44),
                brightness: Brightness.dark,
                primarySwatch: Colors.lightBlue,
                cardColor: main_col,
              );

buttonstyle(Color color) => ButtonStyle(
                  fixedSize: MaterialStateProperty.all<Size>(Size(700,60),),
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
                      )
                  )
                );


