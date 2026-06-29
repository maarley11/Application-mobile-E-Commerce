import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../widgets/manjak_pattern.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart';
import '../../services/api_client.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  Future<void> _downloadInvoice(String orderId, String orderNumber) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Téléchargement de la facture $orderNumber...'),
          backgroundColor: BaanaColors.primary,
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/Facture_$orderNumber.pdf';

      await apiClient.client.download(
        '/orders/$orderId/invoice',
        filePath,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Facture $orderNumber téléchargée !'),
            backgroundColor: BaanaColors.primary,
            action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      debugPrint('Erreur download invoice: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du téléchargement: $e'), backgroundColor: BaanaColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final orderProvider = context.watch<OrderProvider>();
    final deliveredOrders = orderProvider.orders
        .where((o) => o.status == OrderStatus.delivered)
        .toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Mes Factures', style: textTheme.headlineSmall?.copyWith(color: BaanaColors.primary, fontWeight: FontWeight.w800)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: BaanaColors.primary), onPressed: () => context.pop()),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: ArtisticBackgroundPainter())),
          SafeArea(
            child: orderProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: BaanaColors.primary))
                : deliveredOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 80, color: BaanaColors.textSecondary.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            Text('Aucune facture disponible', style: textTheme.titleMedium?.copyWith(color: BaanaColors.textSecondary)),
                            const SizedBox(height: 8),
                            Text('Les factures apparaîtront ici après vos livraisons', style: textTheme.bodyMedium?.copyWith(color: BaanaColors.textSecondary)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(24),
                        itemCount: deliveredOrders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final order = deliveredOrders[index];
                          final dateText = '${order.date.day}/${order.date.month}/${order.date.year}';

                          return ClipRRect(
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: BaanaColors.primary.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Icon(Icons.receipt_long, color: BaanaColors.primary),
                                            ),
                                            const SizedBox(width: 12),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                                                Text(dateText, style: TextStyle(color: BaanaColors.textSecondary, fontSize: 13)),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '${order.totalAmount.toInt()} F',
                                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: BaanaColors.primary),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () => _downloadInvoice(order.id, order.orderNumber),
                                        icon: const Icon(Icons.download, size: 18),
                                        label: const Text('Télécharger la facture PDF'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: BaanaColors.primary,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      ),
                                    ),
                                  ],
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
