import 'dart:math' as math;
import 'package:flutter/material.dart';

class ClockBorderPainter extends CustomPainter {
  final int seconds;
  final Color foregroundColor, color;

  ClockBorderPainter({
    this.seconds,
    this.foregroundColor,
    this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPainter = Paint()
      ..color = color
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;

    // paint the background circle
    _paintCircle(
      canvas,
      size,
      4.5,
      backgroundPainter,
    );

    // paint the arc that 'circles' on top of it
    _paintArc(
      canvas,
      size,
      4.5,
      ((seconds == 0 ? 60 : seconds) / 60) * math.pi * 2,
      backgroundPainter..color = foregroundColor,
    );
  }

  @override
  bool shouldRepaint(ClockBorderPainter old) =>
      seconds != old.seconds ||
      color != old.color ||
      foregroundColor != old.foregroundColor;

  void _paintCircle(Canvas canvas, Size size, double width, Paint paint) {
    canvas.drawCircle(
      size.center(Offset.zero),
      size.width / width,
      paint,
    );
  }

  void _paintArc(Canvas canvas, Size size, double width, double time, Paint paint) {
    canvas.drawArc(
      Rect.fromCircle(
        center: size.center(Offset.zero),
        radius: size.width / width,
      ),
      -math.pi / 2,
      time,
      false,
      paint,
    );
  }
}
