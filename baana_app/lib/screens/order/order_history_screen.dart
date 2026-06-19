import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/colors.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../widgets/manjak_pattern.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String _selectedFilter = 'Toutes';
  final List<String> _filters = ['Toutes', 'En cours', 'Livrées', 'Annulées'];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final orderProvider = context.watch<OrderProvider>();
    
    // Filtrage basique
    List<Order> filteredOrders = orderProvider.orders;
    if (_selectedFilter == 'En cours') {
      filteredOrders = filteredOrders.where((o) => o.status == OrderStatus.pending || o.status == OrderStatus.preparing || o.status == OrderStatus.shipping).toList();
    } else if (_selectedFilter == 'Livrées') {
      filteredOrders = filteredOrders.where((o) => o.status == OrderStatus.delivered).toList();
    }

    return Scaffold(
      backgroundColor: BaanaColors.background,
      appBar: AppBar(
        backgroundColor: BaanaColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: BaanaColors.primary),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          'Mes Commandes',
          style: textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF2C3E36), // quasi-black
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF3c4a42)), // on-surface-variant
            onPressed: () {},
          ),
        ],
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
            child: Column(
              children: [
                // Filters
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = filter == _selectedFilter;
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedFilter = filter),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? BaanaColors.primary : const Color(0xFFf1f4f2), // surface-container-low
                              borderRadius: index % 2 == 0 
                                ? const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(12), bottomLeft: Radius.circular(12), bottomRight: Radius.circular(24))
                                : const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(24), bottomLeft: Radius.circular(24), bottomRight: Radius.circular(12)),
                              border: isSelected ? null : Border.all(color: const Color(0xFFD4DDD8)), // border-muted
                            ),
                            child: Text(
                              filter,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : const Color(0xFF3c4a42),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Orders List
                Expanded(
                  child: orderProvider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: BaanaColors.primary))
                    : filteredOrders.isEmpty
                        ? Center(
                            child: Text('Aucune commande trouvée.', style: textTheme.bodyLarge),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
                            itemCount: filteredOrders.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 24),
                            itemBuilder: (context, index) {
                              final order = filteredOrders[index];
                              return _buildOrderCard(context, order, index);
                            },
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order, int index) {
    final textTheme = Theme.of(context).textTheme;
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'F', decimalDigits: 0);
    final String formattedDate = DateFormat('dd MMM yyyy, HH:mm', 'fr_FR').format(order.date);

    final bool isDelivered = order.status == OrderStatus.delivered;
    final bool isPendingPayment = order.status == OrderStatus.pending;

    Color statusBgColor = isDelivered ? const Color(0xFFE8F5E9) : const Color(0xFFE3F2FD); // success-light or info
    Color statusTextColor = isDelivered ? BaanaColors.primary : Colors.blue;
    String statusText = isDelivered ? 'Livrée' : 'En cours';

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: ClipRRect(
        borderRadius: index % 2 == 0
            ? const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(24), bottomLeft: Radius.circular(24), bottomRight: Radius.circular(12))
            : const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(12), bottomLeft: Radius.circular(12), bottomRight: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: GestureDetector(
            onTap: () => context.push('/order_tracking/${order.id}'),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.65),
                borderRadius: index % 2 == 0
                    ? const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(24), bottomLeft: Radius.circular(24), bottomRight: Radius.circular(12))
                    : const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(12), bottomLeft: Radius.circular(12), bottomRight: Radius.circular(24)),
                border: Border.all(
                  color: Colors.white.withOpacity(0.8),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: BaanaColors.primary.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COMMANDE #${order.id}',
                      style: textTheme.labelSmall?.copyWith(color: const Color(0xFF6B7D75), letterSpacing: 1), // text-secondary
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF181c1c)),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: textTheme.labelSmall?.copyWith(color: statusTextColor, fontWeight: FontWeight.w700, letterSpacing: 0.1),
                  ),
                ),
              ],
            ),
            
            // Alert Banner (if pending)
            if (isPendingPayment) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDAD6).withOpacity(0.3), // error-container
                  border: Border.all(color: const Color(0xFFF97316).withOpacity(0.3)), // cta-orange
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline, color: Color(0xFFF97316), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Paiement en attente', style: textTheme.bodyMedium?.copyWith(color: const Color(0xFFF97316), fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('Veuillez finaliser votre paiement via Wave ou Orange Money.', style: textTheme.bodySmall?.copyWith(color: const Color(0xFF3c4a42))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Items and Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Overlapping Avatars
                Row(
                  children: [
                    for (int i = 0; i < (order.items.length > 2 ? 2 : order.items.length); i++)
                      Align(
                        widthFactor: 0.6,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFe0e3e1), // surface-variant
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.fastfood, size: 20, color: Color(0xFF6B7D75)),
                        ),
                      ),
                    if (order.items.length > 2)
                      Align(
                        widthFactor: 0.6,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFebefed), // surface-container
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: Text('+${order.items.length - 2}', style: textTheme.labelSmall?.copyWith(color: const Color(0xFF6B7D75))),
                        ),
                      ),
                  ],
                ),

                // Total
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Total', style: textTheme.labelSmall?.copyWith(color: const Color(0xFF6B7D75))),
                    Text(
                      currencyFormat.format(order.totalAmount),
                      style: textTheme.headlineSmall?.copyWith(color: BaanaColors.primary, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Action Button
            if (!isDelivered)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316), // cta-orange
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(12), bottomLeft: Radius.circular(12), bottomRight: Radius.circular(24)),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => context.push('/order_tracking/${order.id}'),
                  icon: const Icon(Icons.local_shipping_outlined, color: Colors.white),
                  label: Text('Suivre la livraison', style: textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: BaanaColors.primary, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {},
                        child: Text('Recommander', style: textTheme.titleMedium?.copyWith(color: BaanaColors.primary, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFf1f4f2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD4DDD8)),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.receipt_long, color: Color(0xFF3c4a42)),
                      onPressed: () {},
                    ),
                  )
                ],
              ),
          ],
        ),
      ),
    ),
  ),
),
);
}
}
