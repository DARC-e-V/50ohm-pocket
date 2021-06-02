
import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants.dart';

chapterwidget(var chapterNames,final Color gardientCol) => Container(
    margin: EdgeInsets.only(top: std_padding, bottom: std_padding + 20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          gardientCol,
          Color(0xFFEEEEEE)
        ],
      ),
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    child: Padding(
        padding: EdgeInsets.all(std_padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
                children: [
                  Expanded(child: Text(
                    "$chapterNames",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),)
                ]
            ),
            Card(
              margin: EdgeInsets.only(top: 24,right: 30),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.functions_outlined),
                    title: Text(
                      "Allgemeine mathematische Grundkenntnisse und Größen",
                      style: TextStyle(
                          fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Card(
              margin: EdgeInsets.only(top: 24,right: 30),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.bolt_outlined),
                    title: Text(
                      "Elektrizitäts-, Elektromagnetismus- und Funktheorie",
                      style: TextStyle(
                          fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        )
    )
);

