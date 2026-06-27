import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../widgets/manjak_pattern.dart';
import 'dart:ui';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

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
    final orders = orderProvider.orders;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: BaanaColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          "Mes Commandes",
          style: textTheme.headlineSmall?.copyWith(
            color: BaanaColors.textPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: BaanaColors.primary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: BaanaColors.textPrimary),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Texture Manjak
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = filter == _selectedFilter;
                      // Alternance de borders organiques
                      final isAltBorder = index % 2 != 0;

                      return Padding(
                        padding: const EdgeInsets.only(right: 12, top: 4, bottom: 8),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          borderRadius: _getOrganicBorderRadius(isAltBorder),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? BaanaColors.primary : Colors.white.withOpacity(0.6),
                              borderRadius: _getOrganicBorderRadius(isAltBorder),
                              border: isSelected ? null : Border.all(color: BaanaColors.textSecondary.withOpacity(0.2)),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: BaanaColors.primary.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                filter,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : BaanaColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Orders List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    children: [
                      if (orderProvider.isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(color: BaanaColors.primary),
                          ),
                        )
                      else if (orders.isNotEmpty) ...() {
                        final displayOrders = orders.where((order) {
                          if (_selectedFilter == 'Toutes') return true;
                          if (_selectedFilter == 'En cours') {
                            return order.status == OrderStatus.confirmed ||
                                order.status == OrderStatus.preparing ||
                                order.status == OrderStatus.delivering;
                          }
                          if (_selectedFilter == 'Livrées') {
                            return order.status == OrderStatus.delivered;
                          }
                          if (_selectedFilter == 'Annulées') {
                            return order.status == OrderStatus.cancelled;
                          }
                          return false;
                        }).toList();

                        if (displayOrders.isEmpty) {
                          return [
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.0),
                                child: Text(
                                  'Aucune commande dans cette catégorie',
                                  style: TextStyle(color: BaanaColors.textSecondary, fontSize: 16),
                                ),
                              ),
                            )
                          ];
                        }

                        return displayOrders.map((order) {
                          String statusStr = 'Confirmée';
                          Color statusColor = const Color(0xFF3B9EC4);
                          if (order.status == OrderStatus.preparing) {
                            statusStr = 'En préparation';
                            statusColor = Colors.orange;
                          } else if (order.status == OrderStatus.delivering) {
                            statusStr = 'En cours de livraison';
                            statusColor = const Color(0xFF3B9EC4);
                          } else if (order.status == OrderStatus.delivered) {
                            statusStr = 'Livrée';
                            statusColor = BaanaColors.primary;
                          } else if (order.status == OrderStatus.cancelled) {
                            statusStr = 'Annulée';
                            statusColor = BaanaColors.error;
                          }

                          final dateText = '${order.date.day}/${order.date.month}/${order.date.year}';
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildOrderCard(
                              context,
                              orderId: order.orderNumber,
                              date: dateText,
                              status: statusStr,
                              statusColor: statusColor,
                              total: '${order.totalAmount.toInt()} F',
                              images: order.items.map((i) => 'https://via.placeholder.com/150?text=${Uri.encodeComponent(i.title)}').toList(),
                              isAltBorder: false,
                              isCancelled: order.status == OrderStatus.cancelled,
                              primaryActionText: order.status == OrderStatus.delivering ? 'Suivre la livraison' : null,
                              primaryActionIcon: order.status == OrderStatus.delivering ? Icons.local_shipping_outlined : null,
                              onPrimaryAction: order.status == OrderStatus.delivering ? () {
                                context.push('/order_tracking/${order.id}');
                              } : null,
                            ),
                          );
                        }).toList();
                      }()
                      else ...[
                        if (_selectedFilter == 'Toutes' || _selectedFilter == 'En cours')
                          _buildOrderCard(
                            context,
                            orderId: 'CMD-4920',
                            date: "Aujourd'hui, 14h30",
                            status: 'En cours',
                            statusColor: const Color(0xFF3B9EC4), // Info blue or Success Light
                            total: '12 500 F',
                            images: [
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuAEgDFFhGpG9zkdU3oREPXXDW_ufDQ_GC-oDgp1qmVMGzCUhVORHOlLXyfmEsItMsponPE_-fCJSu_I0etWCd4EfYBN3cPVTgfOg6Vg7TZuf9bfAmL9mF2JDc6THDW1piaAKrgqWTfxxmnnvr2-U2791cTJCZk6UFgXlHpBMIiuiXGpMf20ilzOWdPSfXjezee9839vyHfyvA5TSoNkVYGBEOpNi-drgWGTxZZWNHPDW8bMQnN0CUAF-fUur41SMItY3Q-s8djShQQ',
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuDLBDTy9ijZKGt6hAygCcHZ2WXhDlOPFtsiLUsuf_yU_tKlYTG_i6ZeTOEKjlDLvY1zIhtV8kkzYnsgErt3HvfJz90qMQksmatXhaL0wQuzmzlKGr9aqeHRfV-tXaZ7mjcoy_I7oBhZIIv1Kp7j3YzOjuPoAema0_Rc6GUJkXSa7Ut6KoSJ5dG24llFtXwJsq27tT2mIMpRQIX0eCJFl6Yg_tHCkkw2IApyihyCV47R69qfpH0YqrpA9cMZypbeNImIGJnaD-4aixg',
                            ],
                            extraItemsCount: 2,
                            isAltBorder: true,
                            alertTitle: 'Paiement en attente',
                            alertSubtitle: 'Veuillez finaliser votre paiement via Wave ou Orange Money.',
                            primaryActionText: 'Suivre la livraison',
                            primaryActionIcon: Icons.local_shipping_outlined,
                            onPrimaryAction: () {
                              context.push('/order_tracking/CMD-4920');
                            },
                          ),
                        
                        if (_selectedFilter == 'Toutes' || _selectedFilter == 'Livrées')
                          _buildOrderCard(
                            context,
                            orderId: 'CMD-4811',
                            date: 'Hier, 19h15',
                            status: 'Livrée',
                            statusColor: BaanaColors.primary,
                            total: '8 000 F',
                            images: [
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuDvvmNqdY1n3JBHvufauRjrTjCHATm2qf3yC8ncdlRKOoFlsR3LkMj3nlah5aUIkwj37uFmXqnzjVyo6OuBcWA9kVyeDinmFfBpsIeEx3GTI2tygBK6YgzqlZXgkL5FTqXVoPB2NT3-7sophj12fzHQXGMHZcZsfZtv7oeRtoHRxyZdc6aouQxxTHC6KMmhyzF-6WoQbA79aZ2yneyP0a-g8ZvlwWIGw4gMoTDzHz97-RBbSUzmGOvh5-Cpq7IO7I0F27vJUg4CPtQ',
                            ],
                            isAltBorder: false,
                            primaryActionText: 'Recommander',
                            onPrimaryAction: () {},
                            secondaryActionIcon: Icons.receipt_long_outlined,
                            onSecondaryAction: () {},
                          ),

                        if (_selectedFilter == 'Toutes' || _selectedFilter == 'Annulées')
                          Opacity(
                            opacity: 0.7,
                            child: _buildOrderCard(
                              context,
                              orderId: 'CMD-4705',
                              date: '12 Mai 2026',
                              status: 'Annulée',
                              statusColor: BaanaColors.error,
                              total: '15 000 F',
                              images: [],
                              isAltBorder: true,
                              isCancelled: true,
                            ),
                          ),
                      ],
                      const SizedBox(height: 24),
                      TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Toutes les commandes ont été chargées.'),
                              backgroundColor: BaanaColors.primary,
                            ),
                          );
                        },
                        icon: const Icon(Icons.history, color: BaanaColors.primary),
                        label: const Text(
                          'Voir les commandes plus anciennes',
                          style: TextStyle(color: BaanaColors.primary, fontWeight: FontWeight.bold),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: _getOrganicBorderRadius(false),
                            side: BorderSide(color: BaanaColors.textSecondary.withOpacity(0.2)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BorderRadius _getOrganicBorderRadius(bool isAlt) {
    if (isAlt) {
      return const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(24),
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(12),
      );
    }
    return const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(12),
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(24),
      );
  }

  Widget _buildOrderCard(
    BuildContext context, {
    required String orderId,
    required String date,
    required String status,
    required Color statusColor,
    required String total,
    required List<String> images,
    int extraItemsCount = 0,
    required bool isAltBorder,
    bool isCancelled = false,
    String? alertTitle,
    String? alertSubtitle,
    String? primaryActionText,
    IconData? primaryActionIcon,
    VoidCallback? onPrimaryAction,
    IconData? secondaryActionIcon,
    VoidCallback? onSecondaryAction,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: _getOrganicBorderRadius(isAltBorder),
        border: Border.all(color: BaanaColors.textSecondary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: BaanaColors.textSecondary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: ID + Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'COMMANDE #$orderId',
                    style: textTheme.labelSmall?.copyWith(
                      color: BaanaColors.textSecondary,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: BaanaColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // Alert Banner
          if (alertTitle != null && alertSubtitle != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BaanaColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: BaanaColors.accent.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline, color: BaanaColors.accent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alertTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: BaanaColors.accent),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          alertSubtitle,
                          style: textTheme.bodySmall?.copyWith(color: BaanaColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Images and Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image Stack
              if (images.isNotEmpty)
                SizedBox(
                  width: 120,
                  height: 40,
                  child: Stack(
                    children: [
                      for (int i = 0; i < images.length; i++)
                        Positioned(
                          left: i * 28.0,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              image: DecorationImage(
                                image: NetworkImage(images[i]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      if (extraItemsCount > 0)
                        Positioned(
                          left: images.length * 28.0,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: BaanaColors.inputBackground,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                '+$extraItemsCount',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: BaanaColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              else
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: BaanaColors.inputBackground,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.fastfood_outlined, color: BaanaColors.textSecondary, size: 20),
                ),

              // Total
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total',
                    style: textTheme.bodySmall?.copyWith(color: BaanaColors.textSecondary),
                  ),
                  Text(
                    total,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isCancelled ? BaanaColors.textSecondary : BaanaColors.primary,
                      decoration: isCancelled ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Actions
          if (primaryActionText != null) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPrimaryAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryActionIcon != null ? BaanaColors.accent : Colors.transparent,
                      foregroundColor: primaryActionIcon != null ? Colors.white : BaanaColors.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: primaryActionIcon == null ? const BorderSide(color: BaanaColors.primary, width: 2) : BorderSide.none,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (primaryActionIcon != null) ...[
                          Icon(primaryActionIcon),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          primaryActionText,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                if (secondaryActionIcon != null) ...[
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: onSecondaryAction,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: BaanaColors.inputBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: BaanaColors.textSecondary.withOpacity(0.2)),
                      ),
                      child: Icon(secondaryActionIcon, color: BaanaColors.textSecondary),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
