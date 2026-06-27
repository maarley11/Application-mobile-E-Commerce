import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../config/colors.dart';
import '../config/typography.dart';
import '../providers/auth_provider.dart';
import '../widgets/baana_input.dart';
import '../widgets/baana_button.dart';

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _nineaController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _businessNameController.dispose();
    _nineaController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      final businessName = _businessNameController.text.trim();
      final ninea = _nineaController.text.trim();
      final address = _addressController.text.trim();

      await context.read<AuthProvider>().completeBusinessProfile(
        businessName,
        ninea,
        address,
      );

      if (mounted) context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: BaanaColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: BaanaColors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profil Entreprise',
                    style: TextStyle(
                      fontFamily: BaanaTypography.headlineFont,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: BaanaColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Parlez-nous de votre commerce (PME)',
                    style: TextStyle(
                      fontFamily: BaanaTypography.bodyFont,
                      fontSize: 16,
                      color: BaanaColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  BaanaInput(
                    labelText: 'Nom de la boutique / entreprise',
                    hintText: 'Ex: Chez Maimouna',
                    controller: _businessNameController,
                    keyboardType: TextInputType.text,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Ce champ est requis';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  BaanaInput(
                    labelText: 'NINEA (Optionnel)',
                    hintText: 'Ex: 123456789',
                    controller: _nineaController,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 24),

                  BaanaInput(
                    labelText: 'Adresse de livraison habituelle',
                    hintText: 'Ex: Marché HLM, Boutique 12',
                    controller: _addressController,
                    keyboardType: TextInputType.streetAddress,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Ce champ est requis';
                      return null;
                    },
                  ),
                  const SizedBox(height: 48),

                  BaanaButton(
                    text: 'Terminer l\'inscription',
                    onPressed: _submit,
                    isLoading: context.watch<AuthProvider>().isLoading,
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
