import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../config/colors.dart';
import '../config/typography.dart';
import '../providers/auth_provider.dart';
import '../widgets/baana_button.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _verify(String pin) async {
    FocusScope.of(context).unfocus();
    final authProvider = context.read<AuthProvider>();

    final error = await authProvider.verifyOtp(pin);
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: BaanaColors.error,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connexion réussie !'),
          backgroundColor: BaanaColors.primary,
        ),
      );
      // Redirection vers la page d'accueil à faire au J5
      // context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final phone = context.read<AuthProvider>().currentPhone;

    final defaultPinTheme = PinTheme(
      width: 64,
      height: 64,
      textStyle: TextStyle(
        fontFamily: BaanaTypography.headlineFont,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: BaanaColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: BaanaColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
      ),
    );

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vérification',
                  style: TextStyle(
                    fontFamily: BaanaTypography.headlineFont,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: BaanaColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Un code à 4 chiffres a été envoyé au\n$phone',
                  style: TextStyle(
                    fontFamily: BaanaTypography.bodyFont,
                    fontSize: 16,
                    color: BaanaColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),

                Center(
                  child: Pinput(
                    length: 4,
                    controller: _pinController,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        border: Border.all(color: BaanaColors.primary, width: 2),
                      ),
                    ),
                    errorPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        border: Border.all(color: BaanaColors.error, width: 2),
                      ),
                    ),
                    onCompleted: _verify,
                  ),
                ),
                const SizedBox(height: 48),

                BaanaButton(
                  text: 'Vérifier',
                  onPressed: () {
                    if (_pinController.text.length == 4) {
                      _verify(_pinController.text);
                    }
                  },
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
