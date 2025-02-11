// lib/views/friends/widgets/friend_card.dart
import 'package:flutter/material.dart';

import '../../../models/user.dart';

class FriendCard extends StatelessWidget {
  final User friend;
  final VoidCallback onRemove;

  const FriendCard({
    Key? key,
    required this.friend,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Bannière (si disponible)
          if (friend.banner != null)
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),

          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Text(friend.pseudo[0].toUpperCase()),
            ),
            title: Row(
              children: [
                Text(friend.pseudo),
                if (friend.title != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      friend.title!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.person_remove),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Supprimer cet ami ?'),
                    content: Text('Voulez-vous vraiment supprimer ${friend.pseudo} de votre liste d\'amis ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onRemove();
                        },
                        child: const Text('Supprimer'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}