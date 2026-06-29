import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/theme_provider.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../widgets/manjak_pattern.dart';
import 'dart:ui';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Paramètres',
          style: textTheme.headlineSmall?.copyWith(
            color: BaanaColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: BaanaColors.primary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: ArtisticBackgroundPainter(),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Général'),
                  _buildSettingsContainer(
                    context,
                    children: [
                      _buildSwitchItem(
                        'Notifications Push',
                        Icons.notifications_active_outlined,
                        _notificationsEnabled,
                        (val) => setState(() => _notificationsEnabled = val),
                      ),
                      _buildDivider(),
                      _buildSwitchItem(
                        'Mode Sombre',
                        Icons.dark_mode_outlined,
                        themeProvider.isDarkMode,
                        (val) => themeProvider.toggleDarkMode(),
                      ),
                      _buildDivider(),
                      _buildActionItem(
                        'Langue',
                        Icons.language_outlined,
                        trailingText: themeProvider.locale.languageCode == 'fr' ? 'Français' : 'English',
                        onTap: () {
                          final newLang = themeProvider.locale.languageCode == 'fr' ? 'en' : 'fr';
                          themeProvider.setLocale(newLang);
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('Sécurité'),
                  _buildSettingsContainer(
                    context,
                    children: [
                      _buildActionItem(
                        'Changer le code PIN',
                        Icons.lock_outline,
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildActionItem(
                        'Modifier l\'adresse de livraison',
                        Icons.location_on_outlined,
                        onTap: () {},
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('À propos'),
                  _buildSettingsContainer(
                    context,
                    children: [
                      _buildActionItem(
                        'Conditions générales',
                        Icons.description_outlined,
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildActionItem(
                        'Politique de confidentialité',
                        Icons.privacy_tip_outlined,
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildActionItem(
                        'Version de l\'application',
                        Icons.info_outline,
                        trailingText: 'v1.0.0',
                        showArrow: false,
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: BaanaTypography.headlineFont,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: BaanaColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSettingsContainer(BuildContext context, {required List<Widget> children}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
          ),
          child: Column(
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchItem(String title, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      leading: Icon(icon, color: BaanaColors.primary),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, color: BaanaColors.textPrimary),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: BaanaColors.primary,
      ),
    );
  }

  Widget _buildActionItem(String title, IconData icon, {String? trailingText, bool showArrow = true, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: BaanaColors.primary),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, color: BaanaColors.textPrimary),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(
              trailingText,
              style: const TextStyle(color: BaanaColors.textSecondary, fontWeight: FontWeight.w500),
            ),
          if (showArrow) ...[
            if (trailingText != null) const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16, color: BaanaColors.textSecondary),
          ],
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: BaanaColors.primary.withOpacity(0.1), indent: 16, endIndent: 16);
  }
}
