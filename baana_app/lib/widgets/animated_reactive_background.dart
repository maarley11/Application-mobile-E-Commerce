import 'package:flutter/material.dart';
import 'dart:math';
import '../config/colors.dart';

class AnimatedReactiveBackground extends StatefulWidget {
  final double scrollOffset;
  const AnimatedReactiveBackground({super.key, required this.scrollOffset});

  @override
  State<AnimatedReactiveBackground> createState() => _AnimatedReactiveBackgroundState();
}

class _AnimatedReactiveBackgroundState extends State<AnimatedReactiveBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double pulse = _controller.value;
        final double scroll = widget.scrollOffset;

        return Stack(
          children: [
            // 1. Fond crème doux
            Positioned.fill(
              child: Container(color: const Color(0xFFF7FAF8)),
            ),

            // 2. Liquid Mesh Gradient (Taches de lumières fluides pastel)
            Positioned.fill(
              child: CustomPaint(
                painter: MeshGradientPainter(pulse: pulse, scroll: scroll),
              ),
            ),

            // 3. Filigrane Adinkra (Très grand, très doux, réactif au scroll)
            Positioned(
              top: 100 - (scroll * 0.6),
              right: -100,
              child: Opacity(
                opacity: 0.08,
                child: Transform.rotate(
                  angle: -0.15,
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBZtXMVu9JoIVPR-6TMrJfUM_25GS-q7VbBXukBuJYii-GuN2dxcFZZK0U23O6YrAiTw5VSEIf0_N4Lpe_8WRkR_lMOpsmuzTZNZlQam8XJcepJd-Gx56t9YLPxUu4y4zJn55djoH2pCMwyd6EOSGRVX_oBVxbLETS3pwlsX5R1SWYL-151TJ2Wcvwwj50l99yKhldY_Jawc6hkEmEpO7LCswiO51CIZcoU0ZEq4dQbwe4QxRzNbwL02KQ7bCOAKQ7TxqhK-2TAbAM',
                    width: 500,
                  ),
                ),
              ),
            ),

            // 4. Texture Tissée Manjak (Par-dessus tout pour texturer la lumière)
            Positioned.fill(
              child: CustomPaint(
                painter: ManjakTexturePainter(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class MeshGradientPainter extends CustomPainter {
  final double pulse;
  final double scroll;

  MeshGradientPainter({required this.pulse, required this.scroll});

  @override
  void paint(Canvas canvas, Size size) {
    final double angle = pulse * 2 * pi;

    // Couleurs douces et fluides pour éviter l'effet "moche" ou saturé
    final paint1 = Paint()
      ..color = const Color(0xFFA8E6CF).withOpacity(0.6) // Mint pastel
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);

    final paint2 = Paint()
      ..color = const Color(0xFFFFD3B6).withOpacity(0.5) // Pêche pastel
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);

    final paint3 = Paint()
      ..color = BaanaColors.primary.withOpacity(0.2) // Vert primaire doux
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 140);

    // Dessin des énormes "orbes" liquides qui orbitent doucement
    canvas.drawCircle(
      Offset(
        size.width * 0.2 + cos(angle) * 80,
        size.height * 0.2 + sin(angle) * 80 - (scroll * 0.2),
      ),
      size.width * 0.7,
      paint1,
    );

    canvas.drawCircle(
      Offset(
        size.width * 0.8 + sin(angle) * 120,
        size.height * 0.6 + cos(angle) * 100 - (scroll * 0.4),
      ),
      size.width * 0.6,
      paint2,
    );

    canvas.drawCircle(
      Offset(
        size.width * 0.5 + cos(angle * 1.5) * 150,
        size.height * 0.9 + sin(angle * 1.5) * 100 - (scroll * 0.1),
      ),
      size.width * 0.5,
      paint3,
    );
  }

  @override
  bool shouldRepaint(covariant MeshGradientPainter oldDelegate) => 
      oldDelegate.pulse != pulse || oldDelegate.scroll != scroll;
}

class ManjakTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint dotPaint = Paint()..color = BaanaColors.border.withOpacity(0.2);
    const double spacing = 20.0;
    
    // Dessine une grille de points fine qui donne un effet "Toile/Canvas"
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.8, dotPaint);
        canvas.drawCircle(Offset(x + spacing / 2, y + spacing / 2), 0.8, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
