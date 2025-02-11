// lib/views/profile/widgets/customization_item.dart
import 'package:flutter/material.dart';
import '../../../models/shop_item.dart';
import '../../../config/constants.dart';

class CustomizationItem extends StatelessWidget {
  final ShopItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isLoading;

  const CustomizationItem({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.onTap,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Stack(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(
                item.type == 'banner' ? 8 : 40,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                item.type == 'banner' ? 6 : 38,
              ),
              child: _buildContent(context),
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(
                    item.type == 'banner' ? 8 : 40,
                  ),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (item.type == 'title') {
      return Container(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        child: Center(
          child: Text(
            item.name,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (item.asset?.filePath != null) {
      return Image.network(
        AppConstants.imageUrl(item.asset!.filePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(context);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder(context);
        },
      );
    }

    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Center(
        child: Icon(
          item.type == 'banner' ? Icons.image : Icons.person,
          color: Theme.of(context).primaryColor.withOpacity(0.5),
        ),
      ),
    );
  }
}