import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../widgets/manjak_pattern.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart';
import 'dart:ui';

class ActiveDeliveriesScreen extends StatefulWidget {
  const ActiveDeliveriesScreen({super.key});

  @override
  State<ActiveDeliveriesScreen> createState() => _ActiveDeliveriesScreenState();
}

class _ActiveDeliveriesScreenState extends State<ActiveDeliveriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final orderProvider = context.watch<OrderProvider>();
    final activeOrders = orderProvider.orders
        .where((o) =>
            o.status == OrderStatus.confirmed ||
            o.status == OrderStatus.preparing ||
            o.status == OrderStatus.delivering)
        .toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Suivi des livraisons', style: textTheme.headlineSmall?.copyWith(color: BaanaColors.primary, fontWeight: FontWeight.w800)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: BaanaColors.primary), onPressed: () => context.pop()),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: ArtisticBackgroundPainter())),
          SafeArea(
            child: orderProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: BaanaColors.primary))
                : activeOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_shipping_outlined, size: 80, color: BaanaColors.textSecondary.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            Text('Aucune livraison en cours', style: textTheme.titleMedium?.copyWith(color: BaanaColors.textSecondary)),
                            const SizedBox(height: 8),
                            Text('Vos livraisons actives apparaîtront ici', style: textTheme.bodyMedium?.copyWith(color: BaanaColors.textSecondary)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(24),
                        itemCount: activeOrders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final order = activeOrders[index];
                          String statusStr = 'Confirmée';
                          Color statusColor = BaanaColors.info;
                          IconData statusIcon = Icons.check_circle_outline;

                          if (order.status == OrderStatus.preparing) {
                            statusStr = 'En préparation';
                            statusColor = Colors.orange;
                            statusIcon = Icons.restaurant_outlined;
                          } else if (order.status == OrderStatus.delivering) {
                            statusStr = 'En livraison';
                            statusColor = BaanaColors.info;
                            statusIcon = Icons.local_shipping_outlined;
                          }

                          final dateText = '${order.date.day}/${order.date.month}/${order.date.year}';

                          return GestureDetector(
                            onTap: () => context.push('/order_tracking/${order.id}'),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Icon(statusIcon, color: statusColor, size: 28),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                                            const SizedBox(height: 4),
                                            Text(dateText, style: TextStyle(color: BaanaColors.textSecondary, fontSize: 13)),
                                            const SizedBox(height: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: statusColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(statusStr, style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 12)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text('${order.totalAmount.toInt()} F', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: BaanaColors.primary)),
                                          const SizedBox(height: 8),
                                          const Icon(Icons.chevron_right, color: BaanaColors.textSecondary),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
