import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../config/colors.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../widgets/manjak_pattern.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: false);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final orderProvider = context.watch<OrderProvider>();
    final order = orderProvider.getOrderById(widget.orderId);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Commande introuvable')),
        body: const Center(child: Text('Cette commande n\'existe pas.')),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: BaanaColors.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Commande #${order.id}',
          style: textTheme.titleLarge?.copyWith(
            color: BaanaColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Premium Artistic Background
          Positioned.fill(
            child: CustomPaint(
              painter: ArtisticBackgroundPainter(),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Timeline Section (Glassmorphism)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: BaanaColors.primary.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                  children: [
                    _buildTimelineStep(
                      context,
                      title: 'Confirmée',
                      time: 'Aujourd\'hui, 09:42',
                      isCompleted: true,
                      isCurrent: false,
                      isLast: false,
                    ),
                    _buildTimelineStep(
                      context,
                      title: 'En préparation',
                      time: 'Aujourd\'hui, 10:15',
                      isCompleted: order.status.index >= OrderStatus.preparing.index,
                      isCurrent: order.status == OrderStatus.preparing,
                      isLast: false,
                    ),
                    _buildTimelineStep(
                      context,
                      title: 'En livraison',
                      time: 'Arrivée estimée : 11:30',
                      isCompleted: order.status.index >= OrderStatus.shipping.index,
                      isCurrent: order.status == OrderStatus.shipping,
                      isLast: false,
                    ),
                    _buildTimelineStep(
                      context,
                      title: 'Livrée',
                      time: order.status == OrderStatus.delivered ? 'Aujourd\'hui, 11:45' : 'En attente',
                      isCompleted: order.status == OrderStatus.delivered,
                      isCurrent: false,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Delivery Driver Card (Glassmorphism)
          if (order.status == OrderStatus.shipping || order.status == OrderStatus.delivered)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: BaanaColors.primary.withOpacity(0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  color: const Color(0xFFe0e3e1),
                                ),
                                child: const Icon(Icons.person, color: Color(0xFF6B7D75)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Mamadou Diop', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF181c1c))),
                                    const SizedBox(height: 4),
                                    Text('+221 77 123 45 67', style: textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7D75))),
                                  ],
                                ),
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10b981), // primary-container
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.call, color: Color(0xFF00422b), size: 20),
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

              const SizedBox(height: 32),

              // GPS Mini-map Placeholder (Glassmorphism)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                    ),
                    child: Stack(
                      children: [
                        // Simulated Map Pattern
                        Positioned.fill(
                          child: CustomPaint(
                            painter: MapPatternPainter(),
                          ),
                        ),
                        // Route Line
                        Positioned.fill(
                          child: CustomPaint(
                            painter: RoutePainter(),
                          ),
                        ),
                        // Location Label
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFD4DDD8)),
                            ),
                            child: Text(
                              'Dakar - Plateau',
                              style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF181c1c)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: BaanaColors.primary, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.download, color: BaanaColors.primary),
                  label: Text('Télécharger facture PDF', style: textTheme.titleMedium?.copyWith(color: BaanaColors.primary, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF6c7a71), width: 1), // outline
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.support_agent, color: Color(0xFF3c4a42)), // on-surface-variant
                  label: Text('Contacter support', style: textTheme.titleMedium?.copyWith(color: const Color(0xFF3c4a42), fontWeight: FontWeight.w700)),
                ),
              ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(
    BuildContext context, {
    required String title,
    required String time,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Column (Indicator & Line)
          SizedBox(
            width: 24,
            child: Column(
              children: [
                if (isCompleted && !isCurrent)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10b981), // primary-container
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 14),
                  )
                else if (isCurrent)
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF97316),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF97316).withOpacity(0.5 * (1.2 - _pulseAnimation.value)),
                              blurRadius: 10 * _pulseAnimation.value,
                              spreadRadius: 5 * _pulseAnimation.value,
                            )
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  )
                else
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFe0e3e1), // surface-variant
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFbbcabf), width: 2), // outline-variant
                    ),
                  ),
                
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted ? const Color(0xFF10b981) : const Color(0xFFbbcabf),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Right Column (Content)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isCurrent ? const Color(0xFFF97316) : (isCompleted ? const Color(0xFF181c1c) : const Color(0xFF6B7D75)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: textTheme.bodySmall?.copyWith(
                      color: isCompleted || isCurrent ? const Color(0xFF6B7D75) : const Color(0xFF6c7a71),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFbbcabf).withOpacity(0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;

    const double spacing = 20.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF97316)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
      
    // Create a dashed effect
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.6, size.width * 0.5, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.6, size.height * 0.4, size.width * 0.8, size.height * 0.2);

    canvas.drawPath(dashPath(path, dashArray: CircularIntervalList([5, 5])), paint);

    // Draw start and end circles
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.8), 4, Paint()..color = const Color(0xFF10b981));
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), 4, Paint()..color = const Color(0xFFF97316));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Helper to draw dashed paths
class CircularIntervalList<T> {
  final List<T> _vals;
  int _idx = 0;
  CircularIntervalList(this._vals);
  T get next {
    final res = _vals[_idx++];
    if (_idx >= _vals.length) _idx = 0;
    return res;
  }
}

Path dashPath(Path source, {required CircularIntervalList<double> dashArray}) {
  final dest = Path();
  for (final metric in source.computeMetrics()) {
    double distance = 0.0;
    bool draw = true;
    while (distance < metric.length) {
      final len = dashArray.next;
      if (draw) {
        dest.addPath(metric.extractPath(distance, distance + len), Offset.zero);
      }
      distance += len;
      draw = !draw;
    }
  }
  return dest;
}
