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

    // 2. Liquid Plasma Blobs (Effet Hallucinant de vagues lumineuses liquides)
    final paint1 = Paint()
      ..color = BaanaColors.primary.withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    
    final paint2 = Paint()
      ..color = BaanaColors.accent.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);

    final paint3 = Paint()
      ..color = const Color(0xFF004D40).withOpacity(0.08) // Deep forest green
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90);

    // Formes fluides gigantesques (Plasma)
    final path1 = Path()
      ..moveTo(0, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.5, 0, size.width, size.height * 0.4)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
      
    final path2 = Path()
      ..moveTo(size.width, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.5, 0, size.height * 0.8)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();
      
    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.6), size.width * 0.6, paint3);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.2), size.width * 0.5, paint2);

    // 3. Topographie Dorée Ultra Fine (African Gold threads)
    // Des dizaines de fils d'or qui s'entrecroisent comme une sculpture de lumière
    final goldPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          BaanaColors.accent.withOpacity(0.3),
          BaanaColors.primary.withOpacity(0.2),
          Colors.transparent
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Dessin de multiples courbes imbriquées (Fils d'or en haut)
    for (int i = 0; i < 15; i++) {
      final double offset = i * 15.0;
      final pathGold = Path()
        ..moveTo(-50, size.height * 0.2 + offset)
        ..cubicTo(
            size.width * 0.3, size.height * 0.4 - offset * 1.5,
            size.width * 0.7, size.height * 0.1 + offset * 2,
            size.width + 50, size.height * 0.3 + offset);
      canvas.drawPath(pathGold, goldPaint);
    }
    
    // Fils d'or en bas
    for (int i = 0; i < 10; i++) {
      final double offset = i * 20.0;
      final pathGold2 = Path()
        ..moveTo(size.width + 50, size.height * 0.6 + offset)
        ..cubicTo(
            size.width * 0.6, size.height * 0.8 - offset,
            size.width * 0.2, size.height * 0.5 + offset * 1.5,
            -50, size.height * 0.7 + offset);
      canvas.drawPath(pathGold2, goldPaint);
    }

    // 4. Poussière d'étoiles (Points scintillants subtils)
    final starPaint = Paint()..color = BaanaColors.accent.withOpacity(0.3);
    final random = Random(42); // Seed fixe pour ne pas trembler au scroll
    for (int i = 0; i < 150; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        random.nextDouble() * 1.5,
        starPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
