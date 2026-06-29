import 'package:flutter/material.dart';
import '../config/colors.dart';

class BaanaImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const BaanaImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    Widget defaultErrorBuilder(BuildContext context, Object error, StackTrace? stackTrace) {
      return Container(
        color: BaanaColors.inputBackground,
        width: width,
        height: height,
        child: const Center(
          child: Icon(Icons.image_not_supported, color: BaanaColors.textSecondary),
        ),
      );
    }

    final actualErrorBuilder = errorBuilder ?? defaultErrorBuilder;

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: actualErrorBuilder,
      );
    } else {
      return Image.asset(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: actualErrorBuilder,
      );
    }
  }
}
