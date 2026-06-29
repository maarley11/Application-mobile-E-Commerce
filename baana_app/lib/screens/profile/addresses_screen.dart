import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../widgets/manjak_pattern.dart';
import '../../services/api_client.dart';
import 'dart:ui';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<dynamic> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    setState(() => _isLoading = true);
    try {
      final response = await apiClient.client.get('/addresses');
      if (response.statusCode == 200) {
        setState(() => _addresses = response.data);
      }
    } catch (e) {
      debugPrint('Erreur fetchAddresses: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAddress(int id) async {
    try {
      await apiClient.client.delete('/addresses/$id');
      _fetchAddresses();
    } catch (e) {
      debugPrint('Erreur deleteAddress: $e');
    }
  }

  void _showAddressDialog({Map<String, dynamic>? existing}) {
    final labelController = TextEditingController(text: existing?['label'] ?? '');
    final addressController = TextEditingController(text: existing?['fullAddress'] ?? '');
    final phoneController = TextEditingController(text: existing?['phone'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          existing != null ? 'Modifier l\'adresse' : 'Nouvelle adresse',
          style: TextStyle(fontFamily: BaanaTypography.headlineFont, fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                decoration: InputDecoration(
                  labelText: 'Nom (ex: Maison, Bureau)',
                  prefixIcon: const Icon(Icons.label_outline, color: BaanaColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: BaanaColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Adresse complète',
                  prefixIcon: const Icon(Icons.location_on_outlined, color: BaanaColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: BaanaColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Téléphone (optionnel)',
                  prefixIcon: const Icon(Icons.phone_outlined, color: BaanaColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: BaanaColors.primary, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: BaanaColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (addressController.text.trim().isEmpty) return;
              try {
                if (existing != null) {
                  await apiClient.client.put('/addresses/${existing['id']}', data: {
                    'label': labelController.text.trim(),
                    'fullAddress': addressController.text.trim(),
                    'phone': phoneController.text.trim(),
                  });
                } else {
                  await apiClient.client.post('/addresses', data: {
                    'label': labelController.text.trim().isEmpty ? 'Maison' : labelController.text.trim(),
                    'fullAddress': addressController.text.trim(),
                    'phone': phoneController.text.trim(),
                  });
                }
                if (mounted) Navigator.pop(context);
                _fetchAddresses();
              } catch (e) {
                debugPrint('Erreur save address: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BaanaColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(existing != null ? 'Modifier' : 'Ajouter', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Mes Adresses', style: textTheme.headlineSmall?.copyWith(color: BaanaColors.primary, fontWeight: FontWeight.w800)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: BaanaColors.primary), onPressed: () => context.pop()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddressDialog(),
        backgroundColor: BaanaColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: ArtisticBackgroundPainter())),
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: BaanaColors.primary))
                : _addresses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_off_outlined, size: 80, color: BaanaColors.textSecondary.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            Text('Aucune adresse enregistrée', style: textTheme.titleMedium?.copyWith(color: BaanaColors.textSecondary)),
                            const SizedBox(height: 8),
                            Text('Ajoutez votre première adresse de livraison', style: textTheme.bodyMedium?.copyWith(color: BaanaColors.textSecondary)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(24),
                        itemCount: _addresses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final addr = _addresses[index];
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
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: BaanaColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(Icons.location_on, color: BaanaColors.primary, size: 28),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(addr['label'] ?? 'Adresse', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: BaanaColors.textPrimary)),
                                              if (addr['isDefault'] == true) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(color: BaanaColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                                  child: const Text('Par défaut', style: TextStyle(fontSize: 10, color: BaanaColors.primary, fontWeight: FontWeight.w600)),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(addr['fullAddress'] ?? '', style: TextStyle(color: BaanaColors.textSecondary, fontSize: 13)),
                                          if (addr['phone'] != null && addr['phone'].toString().isNotEmpty)
                                            Text(addr['phone'], style: TextStyle(color: BaanaColors.textSecondary, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') _showAddressDialog(existing: addr);
                                        if (value == 'delete') _deleteAddress(addr['id']);
                                      },
                                      itemBuilder: (_) => [
                                        const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                                        const PopupMenuItem(value: 'delete', child: Text('Supprimer', style: TextStyle(color: BaanaColors.error))),
                                      ],
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
