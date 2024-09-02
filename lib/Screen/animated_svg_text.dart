import 'package:flutter/material.dart';

class AnimatedTextPainter extends CustomPainter {
  final String text;
  final TextStyle style;
  final int currentLetterIndex;

  AnimatedTextPainter({
    required this.text,
    required this.style,
    required this.currentLetterIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(text: text.substring(0, currentLetterIndex), style: style),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width);

    final offset = Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2);
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
