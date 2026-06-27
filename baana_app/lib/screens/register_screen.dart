import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../config/colors.dart';
import '../config/typography.dart';
import '../providers/auth_provider.dart';
import '../widgets/baana_input.dart';
import '../widgets/baana_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  
  // Champs profil entreprise (CDC)
  final _businessNameController = TextEditingController();
  final _nineaController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _businessNameController.dispose();
    _nineaController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      // Masquer le clavier
      FocusScope.of(context).unfocus();

      final authProvider = context.read<AuthProvider>();
      
      // L'API s'attend à ce que le numéro commence par +221
      final phone = '+221${_phoneController.text.trim()}';
      final name = _nameController.text.trim();
      final businessName = _businessNameController.text.trim();
      final ninea = _nineaController.text.trim();
      final address = _addressController.text.trim();

      final error = await authProvider.register(phone, name, businessName, ninea, address);

      if (error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: BaanaColors.error,
          ),
        );
      } else if (mounted) {
        context.push('/otp');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: BaanaColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: context.canPop() 
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: BaanaColors.textPrimary),
                onPressed: () => context.pop(),
              )
            : null,
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
                    'Inscription',
                    style: TextStyle(
                      fontFamily: BaanaTypography.headlineFont,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: BaanaColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Créez votre compte pour commencer',
                    style: TextStyle(
                      fontFamily: BaanaTypography.bodyFont,
                      fontSize: 16,
                      color: BaanaColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  BaanaInput(
                    labelText: 'Nom complet',
                    hintText: 'Ex: Mouhamed Dioum',
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Ce champ est requis';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  BaanaInput(
                    labelText: 'Numéro de téléphone',
                    hintText: '77 123 45 67',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Text(
                        '+221',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: BaanaColors.textPrimary,
                        ),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Ce champ est requis';
                      if (val.trim().length < 9) return 'Numéro invalide';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  Text(
                    'Profil Entreprise',
                    style: TextStyle(
                      fontFamily: BaanaTypography.headlineFont,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: BaanaColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
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
                    text: 'Créer mon compte',
                    onPressed: _submit,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        'Déjà un compte ? Se connecter',
                        style: TextStyle(
                          fontFamily: BaanaTypography.bodyFont,
                          color: BaanaColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
