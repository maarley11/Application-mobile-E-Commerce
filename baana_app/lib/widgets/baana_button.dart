import 'package:flutter/material.dart';
import '../config/colors.dart';

enum BaanaButtonVariant { primary, secondary, outline }

class BaanaButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final BaanaButtonVariant variant;
  final bool isFullWidth;
  final bool isLoading;

  const BaanaButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = BaanaButtonVariant.primary,
    this.isFullWidth = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    BorderSide border;

    switch (variant) {
      case BaanaButtonVariant.primary:
        bgColor = BaanaColors.cta; // Orange CTA
        textColor = Colors.white;
        border = BorderSide.none;
        break;
      case BaanaButtonVariant.secondary:
        bgColor = BaanaColors.primary; // Vert
        textColor = Colors.white;
        border = BorderSide.none;
        break;
      case BaanaButtonVariant.outline:
        bgColor = Colors.transparent;
        textColor = BaanaColors.textPrimary;
        border = const BorderSide(color: BaanaColors.border, width: 1.5);
        break;
    }

    Widget content = isLoading
        ? SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              color: textColor,
              strokeWidth: 2.5,
            ),
          )
        : Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          );

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: border,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        minimumSize: const Size(0, 52), // Hauteur minimale 52px (Anti-AI slop)
      ),
      child: content,
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
