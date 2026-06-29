import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/baana_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'mobile_money'; // 'mobile_money' ou 'cash'
  String? _customAddress;
  LatLng? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final authProvider = context.watch<AuthProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final isPro = authProvider.isPro;
    final freeDeliveriesLeft = authProvider.freeDeliveriesLeft;
    
    final currentAddress = _customAddress ?? 
        (authProvider.address.isNotEmpty ? authProvider.address : 'Quartier Almadies, Rue 10, Dakar, Sénégal');

    return Scaffold(
      backgroundColor: BaanaColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Paiement',
          style: TextStyle(
            fontFamily: BaanaTypography.headlineFont,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: BaanaColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: BaanaColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Adresse de livraison'),
            const SizedBox(height: 16),
            _buildAddressCard(currentAddress),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Méthode de paiement'),
            const SizedBox(height: 16),
            _buildPaymentMethodOption(
              id: 'mobile_money',
              title: 'Mobile Money (Wave, Orange, Free)',
              icon: Icons.phone_android,
              isSelected: _selectedPaymentMethod == 'mobile_money',
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodOption(
              id: 'cash',
              title: 'Paiement à la livraison',
              icon: Icons.money,
              isSelected: _selectedPaymentMethod == 'cash',
            ),

            const SizedBox(height: 32),
            _buildSectionTitle('Résumé de la commande'),
            const SizedBox(height: 16),
            _buildOrderSummary(cartProvider, isPro, freeDeliveriesLeft),
            
            const SizedBox(height: 48),
            BaanaButton(
              text: 'Confirmer & Payer',
              isLoading: orderProvider.isLoading,
              onPressed: () async {
                if (cartProvider.items.isEmpty) return;

                final items = cartProvider.items.values.map((item) {
                  return {
                    'productId': item.product.id,
                    'quantity': item.quantity,
                    'price': isPro ? item.product.proPrice : item.product.publicPrice,
                  };
                }).toList();

                final totalAmount = cartProvider.getTotalAmount(isPro, freeDeliveriesLeft);

                try {
                  await orderProvider.createOrder(
                    items, 
                    totalAmount, 
                    _selectedPaymentMethod,
                    deliveryLatitude: _selectedLocation?.latitude,
                    deliveryLongitude: _selectedLocation?.longitude,
                  );
                  
                  if (!mounted) return;

                  if (_selectedPaymentMethod == 'mobile_money') {
                    context.push('/payment_mobile_money');
                  } else {
                    cartProvider.clear();
                    context.push('/confirmation');
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: BaanaTypography.headlineFont,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: BaanaColors.textPrimary,
      ),
    );
  }

  Widget _buildAddressCard(String currentAddress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BaanaColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: BaanaColors.inputBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on, color: BaanaColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Domicile',
                  style: TextStyle(
                    fontFamily: BaanaTypography.headlineFont,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: BaanaColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentAddress,
                  style: TextStyle(
                    fontFamily: BaanaTypography.bodyFont,
                    fontSize: 14,
                    color: BaanaColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.map_outlined, color: BaanaColors.primary),
            onPressed: () {
              // Sur Web : saisie manuelle des coordonnées
              if (kIsWeb) {
                showDialog(
                  context: context,
                  builder: (context) {
                    final latCtrl = TextEditingController(text: _selectedLocation?.latitude.toString() ?? '14.7167');
                    final lngCtrl = TextEditingController(text: _selectedLocation?.longitude.toString() ?? '-17.4677');
                    return AlertDialog(
                      title: const Text('Coordonnées GPS'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: latCtrl,
                            decoration: const InputDecoration(labelText: 'Latitude'),
                            keyboardType: TextInputType.number,
                          ),
                          TextField(
                            controller: lngCtrl,
                            decoration: const InputDecoration(labelText: 'Longitude'),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedLocation = LatLng(
                                double.tryParse(latCtrl.text) ?? 14.7167,
                                double.tryParse(lngCtrl.text) ?? -17.4677,
                              );
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Valider', style: TextStyle(color: BaanaColors.primary)),
                        ),
                      ],
                    );
                  },
                );
              } else {
                // Sur Mobile : carte Google Maps
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    LatLng tempLocation = _selectedLocation ?? const LatLng(14.7167, -17.4677);
                    return Container(
                      height: MediaQuery.of(context).size.height * 0.8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Column(
                        children: [
                          AppBar(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            title: const Text('Pointer sur la carte', style: TextStyle(color: Colors.black)),
                            leading: IconButton(
                              icon: const Icon(Icons.close, color: Colors.black),
                              onPressed: () => Navigator.pop(context),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  setState(() { _selectedLocation = tempLocation; });
                                  Navigator.pop(context);
                                },
                                child: const Text('Valider', style: TextStyle(color: BaanaColors.primary, fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                          Expanded(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                GoogleMap(
                                  initialCameraPosition: CameraPosition(target: tempLocation, zoom: 14),
                                  onCameraMove: (position) { tempLocation = position.target; },
                                  zoomControlsEnabled: false,
                                  myLocationEnabled: true,
                                ),
                                const Icon(Icons.location_pin, color: BaanaColors.primary, size: 40),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: BaanaColors.primary),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  final controller = TextEditingController(text: currentAddress);
                  return AlertDialog(
                    title: const Text('Modifier l\'adresse de livraison'),
                    content: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Saisissez votre adresse',
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: BaanaColors.primary),
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _customAddress = controller.text;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Enregistrer', style: TextStyle(color: BaanaColors.primary)),
                      ),
                    ],
                  );
                },
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption({
    required String id,
    required String title,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? BaanaColors.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? BaanaColors.primary : BaanaColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? BaanaColors.primary : BaanaColors.textSecondary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: BaanaTypography.headlineFont,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? BaanaColors.primary : BaanaColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: BaanaColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider provider, bool isPro, int freeDeliveriesLeft) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BaanaColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sous-total',
                style: TextStyle(
                  fontFamily: BaanaTypography.bodyFont,
                  color: BaanaColors.textSecondary,
                ),
              ),
              Text(
                '${provider.subtotalAmount(isPro).toInt()} FCFA',
                style: TextStyle(
                  fontFamily: BaanaTypography.bodyFont,
                  fontWeight: FontWeight.w600,
                  color: BaanaColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Livraison',
                style: TextStyle(
                  fontFamily: BaanaTypography.bodyFont,
                  color: BaanaColors.textSecondary,
                ),
              ),
              Text(
                provider.getDeliveryFee(isPro, freeDeliveriesLeft) == 0 ? 'Gratuite' : '${provider.getDeliveryFee(isPro, freeDeliveriesLeft)} FCFA',
                style: TextStyle(
                  fontFamily: BaanaTypography.bodyFont,
                  fontWeight: FontWeight.w600,
                  color: provider.getDeliveryFee(isPro, freeDeliveriesLeft) == 0 ? BaanaColors.primary : BaanaColors.textPrimary,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontFamily: BaanaTypography.headlineFont,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: BaanaColors.textPrimary,
                ),
              ),
              Text(
                '${provider.getTotalAmount(isPro, freeDeliveriesLeft)} FCFA',
                style: TextStyle(
                  fontFamily: BaanaTypography.headlineFont,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: BaanaColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
