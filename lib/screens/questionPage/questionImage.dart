import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget questionImage(BuildContext context, String url) {
  List<String> illegalImages = ["BE207_q", "NF106_q", "BE209_q", "NF104_q", "NF102_q", "NF105_q", "BE208_q", "NE209_q", "NG302_q", "NF103_q", "NF101_q"];
  Widget image;
  double imageScaleWidth = min(MediaQuery.sizeOf(context).width * 0.8, 500);
  ColorFilter colorFilter =
  MediaQuery.of(context).platformBrightness == Brightness.dark
      ? ColorFilter.matrix(<double>[
    -1.0, 0.0, 0.0, 0.0, 255.0,
    0.0, -1.0, 0.0, 0.0, 255.0,
    0.0, 0.0, -1.0, 0.0, 255.0,
    0.0, 0.0, 0.0, 1.0, 0.0,
  ])
      : ColorFilter.matrix(<double>[
    1.0, 0.0, 0.0, 0.0, 0.0,
    0.0, 1.0, 0.0, 0.0, 0.0,
    0.0, 0.0, 1.0, 0.0, 0.0,
    0.0, 0.0, 0.0, 1.0, 0.0,
  ]);

  if(illegalImages.contains(url)){
    image = Padding(
      padding: const EdgeInsets.all(8.0),
      child: ColorFiltered(
          colorFilter: colorFilter,
          child: Image.asset("assets/svgs/$url.png",
              width: imageScaleWidth)
      ),
    );
  } else {
    image = SvgPicture.asset(
        "assets/svgs/$url.svg",
        colorFilter: colorFilter,
        width: imageScaleWidth
    );
  };
  return image;
}