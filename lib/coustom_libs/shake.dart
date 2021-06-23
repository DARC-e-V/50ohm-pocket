/*
Copied from https://github.com/FayaPay/flutter-shake-anim under the following MIT Licence.

MIT License

Copyright (c) 2019 Chima Precious

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/


import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

class ShakeView extends StatelessWidget {
  final Widget child;
  final ShakeController controller;
  final Animation _anim;

  ShakeView({required this.child, required this.controller})
      : _anim = Tween<double>(begin: 50, end: 120).animate(controller);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        child: child,
        builder: (context, child) => Transform(
          child: child,
          transform: Matrix4.translation(_shake(_anim.value)),
        ));
  }

  Vector3 _shake(double progress) {
    double offset = sin(progress * pi * 10.0);
    return Vector3(offset * 4, 0.0, 0.0);
  }
}

class ShakeController extends AnimationController {
  ShakeController(
      {required TickerProvider vsync,
        Duration duration = const Duration(milliseconds: 200)})
      : super(vsync: vsync, duration: duration);

  shake() async {
    if (status == AnimationStatus.completed) {
      await this.reverse();
    } else {
      await this.forward();
    }
  }
}
