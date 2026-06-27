import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/colors.dart';
import '../../providers/auth_provider.dart';

class SubscriptionPaymentScreen extends StatefulWidget {
  final String plan;

  const SubscriptionPaymentScreen({Key? key, required this.plan}) : super(key: key);

  @override
  State<SubscriptionPaymentScreen> createState() => _SubscriptionPaymentScreenState();
}

class _SubscriptionPaymentScreenState extends State<SubscriptionPaymentScreen> {
  String _selectedMethod = 'wave';
  final TextEditingController _phoneController = TextEditingController();

  int get _amount {
    return widget.plan.toLowerCase() == 'hebdo' ? 2500 : 7500;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _processPayment() async {
    try {
      // Activer l'abonnement dans l'état global via l'API
      await context.read<AuthProvider>().activateSubscription(widget.plan);
      
      if (mounted) {
        // Navigate to confirmation
        context.push('/subscription_confirmation', extra: widget.plan);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

    return Scaffold(
      backgroundColor: BaanaColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: BaanaColors.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Paiement',
          style: textTheme.titleLarge?.copyWith(
            color: BaanaColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Color(0xFF3c4a42)),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary Section (Glassmorphism)
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Montant à payer',
                          style: textTheme.titleMedium?.copyWith(color: const Color(0xFF6B7D75)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currencyFormat.format(_amount),
                          style: textTheme.headlineMedium?.copyWith(
                            color: BaanaColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFFD4DDD8)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Plan ${widget.plan.toUpperCase()}',
                              style: textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B7D75)),
                            ),
                            Text(
                              'Boutique Pro',
                              style: textTheme.bodyLarge?.copyWith(
                                color: const Color(0xFF181c1c),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Payment Methods
              Text(
                'Choisissez un moyen de paiement',
                style: textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF2C3E36),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildPaymentMethod(
                id: 'wave',
                name: 'Wave',
                description: 'Paiement rapide et sécurisé',
                iconUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAV3br3pvfIvIuobDAo3Z307BxJgwZEKGRkRVNG0NlyaUkhVFjKCfUg2d4fw-l_Jkkcl-HL5mzUmLwvdeZ9l_XN1YRGOmMqmv6FnNr8K7vA0o1yZV2ftI9KsfPDbFgkw5vwi-yWp7VxnWgFc5XDSuKasJ5pnho6g4em-5MkGhFdz2vNwYvPQb7XVHFrcM92ZxtBj_XTY_2N2dRalftvUSfnCn9D4HESQE3hHu5FqBkBhabzTIE3-wHyjD6u9XuZ9PjCqkA85Rs8nx0',
              ),
              const SizedBox(height: 12),
              _buildPaymentMethod(
                id: 'orange_money',
                name: 'Orange Money',
                description: 'Via votre compte mobile',
                iconUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuB2oYGIX1bjjEAdyA_zpE0geECkAsiBa1BddT3cdwZs2xOfb7NswNeNtP0scIAa8lYOQHLxREF9bDruUVMoCgqCgtuPJMJXkveJ5RH_rYtu0wD-mGdTPucT5NIJ22K3wP9cUv1jpj_VSGpiTio1LUtHnJAjA49IYOjEXC21c1CEWJ1wbvmUDzgPhEEo0CgLXY_25UNQeZK1FAbq-7aCo4-pcJ3rYQ8CQePBYugSrWhYj7jd6eBHmF0a5Nj6N6LViB29zq-jmLsljbU',
              ),
              const SizedBox(height: 12),
              _buildPaymentMethod(
                id: 'free_money',
                name: 'Free Money',
                description: 'Paiement mobile simple',
                iconUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCqpjIDe27tuf1ZSmZ490HaP_5UjNzrh_F-UQcGuwzWIbpPFh39ZdtJ99tTdpzEVKjnh5YUj_aoAxHYEroUQqUylbjGNd_t2Bf3J7e4p55i8zk2KLDyPMtH3XpnyP7ZBF9JQ16Kssw3h7k5Xni3CMEGyTd3lGSOZrvhKKpNNLHBSTjDNlhDkbwYsGC5xfCrbo6X4frG9xO6_YS3g6DvxkNiTtOrtIQ0gs4Q_FX7ibdwM66_2VAelVqrg20lkxnEyOOhTZjDqWNm3Mo',
              ),
              
              const SizedBox(height: 32),
              
              // Dynamic Input Area
              if (_selectedMethod != 'card') ...[
                Text(
                  'Numéro de téléphone',
                  style: textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF181c1c),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF2EF), // surface-input
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '+221',
                          style: textTheme.bodyLarge?.copyWith(color: const Color(0xFF6B7D75)),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '77 000 00 00',
                            hintStyle: TextStyle(color: Color(0xFFbbcabf)), // outline-variant
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 48),
              
              // Action Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _processPayment,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Payer ${currencyFormat.format(_amount)}',
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, size: 16, color: Color(0xFF6B7D75)),
                  const SizedBox(width: 4),
                  Text(
                    'Paiement 100% sécurisé',
                    style: textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7D75)),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethod({
    required String id,
    required String name,
    required String description,
    required String iconUrl,
  }) {
    final bool isSelected = _selectedMethod == id;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFf1f4f2) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? BaanaColors.primary : const Color(0xFFD4DDD8),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD4DDD8)),
              ),
              child: Image.network(iconUrl, fit: BoxFit.contain),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF181c1c),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7D75)),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? BaanaColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? BaanaColors.primary : const Color(0xFFbbcabf),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
