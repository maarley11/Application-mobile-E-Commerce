import 'package:flutter/material.dart';
import 'dart:math';
import '../config/colors.dart';

class ArtisticBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Fond crème très profond
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = BaanaColors.background,
    );

    // 2. Motif à points subtils (Dot Pattern) au lieu des vagues
    final dotPaint = Paint()
      ..color = BaanaColors.border.withValues(alpha: 0.5) // Couleur des points subtils
      ..style = PaintingStyle.fill;

    const double spacing = 20.0;
    const double radius = 1.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
