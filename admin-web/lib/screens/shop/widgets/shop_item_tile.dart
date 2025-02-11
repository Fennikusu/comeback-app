// lib/screens/shop/widgets/shop_item_tile.dart
import 'package:flutter/material.dart';
import '../../../models/shop_item.dart';

class ShopItemTile extends StatelessWidget {
  final ShopItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  static const String baseApiUrl = 'http://192.168.1.12/api/public';

  const ShopItemTile({
    Key? key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: [
          InkWell(
            onTap: onEdit,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _buildPreview(context)),
                  const SizedBox(height: 8),
                  Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${item.price} coins',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    if (item.type == 'title') {
      return Container(
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
            ),
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
          '$baseApiUrl/${item.asset!.filePath}',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildPlaceholder(context),
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
          color: Theme.of(context).primaryColor.withOpacity(0.5),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer cet item ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (result == true) {
      onDelete();
    }
  }
}
