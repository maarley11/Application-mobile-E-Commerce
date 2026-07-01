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

  String tr(BuildContext context, String fr, String en) {
    return context.watch<ThemeProvider>().locale.languageCode == 'en' ? en : fr;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final textColor = isDark ? Colors.white : BaanaColors.textPrimary;
    final containerBg = isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.5);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          tr(context, 'Paramètres', 'Settings'),
          style: textTheme.headlineSmall?.copyWith(
            color: isDark ? Colors.white : BaanaColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : BaanaColors.primary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          if (!isDark)
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
                  _buildSectionTitle(tr(context, 'Général', 'General'), textColor),
                  _buildSettingsContainer(
                    context,
                    containerBg,
                    children: [
                      _buildSwitchItem(
                        tr(context, 'Notifications Push', 'Push Notifications'),
                        Icons.notifications_active_outlined,
                        _notificationsEnabled,
                        (val) => setState(() => _notificationsEnabled = val),
                        textColor,
                      ),
                      _buildDivider(),
                      _buildSwitchItem(
                        tr(context, 'Mode Sombre', 'Dark Mode'),
                        Icons.dark_mode_outlined,
                        isDark,
                        (val) => themeProvider.toggleDarkMode(),
                        textColor,
                      ),
                      _buildDivider(),
                      _buildActionItem(
                        tr(context, 'Langue', 'Language'),
                        Icons.language_outlined,
                        textColor,
                        trailingText: themeProvider.locale.languageCode == 'fr' ? 'Français' : 'English',
                        onTap: () {
                          final newLang = themeProvider.locale.languageCode == 'fr' ? 'en' : 'fr';
                          themeProvider.setLocale(newLang);
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle(tr(context, 'Sécurité', 'Security'), textColor),
                  _buildSettingsContainer(
                    context,
                    containerBg,
                    children: [
                      _buildActionItem(
                        tr(context, 'Changer le code PIN', 'Change PIN code'),
                        Icons.lock_outline,
                        textColor,
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildActionItem(
                        tr(context, 'Modifier l\'adresse de livraison', 'Edit delivery address'),
                        Icons.location_on_outlined,
                        textColor,
                        onTap: () {},
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle(tr(context, 'À propos', 'About'), textColor),
                  _buildSettingsContainer(
                    context,
                    containerBg,
                    children: [
                      _buildActionItem(
                        tr(context, 'Conditions générales', 'Terms & Conditions'),
                        Icons.description_outlined,
                        textColor,
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildActionItem(
                        tr(context, 'Politique de confidentialité', 'Privacy Policy'),
                        Icons.privacy_tip_outlined,
                        textColor,
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildActionItem(
                        tr(context, 'Version de l\'application', 'App Version'),
                        Icons.info_outline,
                        textColor,
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

  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: BaanaTypography.headlineFont,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildSettingsContainer(BuildContext context, Color containerBg, {required List<Widget> children}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: containerBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
          ),
          child: Column(
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchItem(String title, IconData icon, bool value, ValueChanged<bool> onChanged, Color textColor) {
    return ListTile(
      leading: Icon(icon, color: BaanaColors.primaryLight),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: BaanaColors.primaryLight,
      ),
    );
  }

  Widget _buildActionItem(String title, IconData icon, Color textColor, {String? trailingText, bool showArrow = true, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: BaanaColors.primaryLight),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
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

