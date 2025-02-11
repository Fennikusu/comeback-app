// lib/views/shop/widgets/shop_item_card.dart
import 'package:flutter/material.dart';
import '../../../models/shop_item.dart';
import '../../../config/constants.dart';

class ShopItemCard extends StatelessWidget {
  final ShopItem item;
  final int currentCoins;

  const ShopItemCard({
    Key? key,
    required this.item,
    required this.currentCoins,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLocked = !item.isUnlocked;

    return Card(
      margin: const EdgeInsets.only(right: 16, bottom: 8),
      child: Stack(
        children: [
          Container(
            width: 160,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Preview de l'item
                Expanded(
                  child: _buildPreview(context),
                ),
                const SizedBox(height: 8),
                // Nom et Status
                Column(
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isLocked ? Colors.grey : Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    if (isLocked)
                      Text(
                        '${item.price} coins',
                        style: TextStyle(
                          color: currentCoins >= item.price
                              ? Theme.of(context).primaryColor
                              : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Débloqué',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (isLocked)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    currentCoins >= item.price
                        ? Icons.lock_open
                        : Icons.lock,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    if (item.type == 'title') {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            item.name,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (item.asset?.filePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(
          item.type == 'banner' ? 8 : 50,
        ),
        child: Image.network(
          '${AppConstants.baseApiUrl}/${item.asset!.filePath}',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
        ),
      );
    }

    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(
          item.type == 'banner' ? 8 : 50,
        ),
      ),
      child: Center(
        child: Icon(
          item.type == 'banner' ? Icons.image : Icons.person,
          size: 32,
          color: Theme.of(context).primaryColor.withOpacity(0.5),
        ),
      ),
    );
  }
}