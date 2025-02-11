// lib/views/profile/widgets/banner_preview.dart
import 'package:flutter/material.dart';
import '../../../config/constants.dart';

class BannerPreview extends StatelessWidget {
  final String? banner;
  final Color defaultColor;

  const BannerPreview({
    Key? key,
    this.banner,
    required this.defaultColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (banner == null || banner == '1') {
      return Container(color: defaultColor);
    }

    return Image.network(
      AppConstants.bannerImage(banner!),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(color: defaultColor);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Stack(
          children: [
            Container(color: defaultColor),
            const Center(child: CircularProgressIndicator()),
          ],
        );
      },
    );
  }
}