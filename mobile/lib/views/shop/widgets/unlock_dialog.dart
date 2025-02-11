import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../models/shop_item.dart';

class UnlockDialog extends StatelessWidget {
  final List<ShopItem> unlockedItems;

  const UnlockDialog({
    Key? key,
    required this.unlockedItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouveaux débloquages !'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Félicitations ! Vous avez débloqué :'),
          const SizedBox(height: 16),
          ...unlockedItems.map((item) => ListTile(
            leading: const Icon(Icons.stars, color: Colors.amber),
            title: Text(item.name),
            subtitle: Text(item.type),
          )),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Super !'),
        ),
      ],
    );
  }
}