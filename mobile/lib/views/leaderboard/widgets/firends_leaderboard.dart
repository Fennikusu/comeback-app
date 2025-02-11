// lib/views/leaderboard/widgets/friends_leaderboard.dart
import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../../../config/constants.dart';

class FriendsLeaderboard extends StatelessWidget {
  final List<User> friends;

  const FriendsLeaderboard({
    Key? key,
    required this.friends,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (friends.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: Theme.of(context).primaryColor.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Aucun ami trouvé',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Ajoutez des amis pour voir leur classement ici',
                style: TextStyle(
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Naviguer vers la page d'ajout d'amis
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Ajouter des amis'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Rank
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _getRankColor(index),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: index <= 2 ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  backgroundImage: friend.profilePicture != '1'
                      ? NetworkImage(AppConstants.profileImage(friend.profilePicture))
                      : null,
                  child: friend.profilePicture == '1'
                      ? Text(
                    friend.pseudo[0].toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                      : null,
                ),
                const SizedBox(width: 12),

                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friend.pseudo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (friend.title != null) ...[
                        const SizedBox(height: 4),
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
                ),

                // Coins
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${friend.coins} coins',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.grey.shade400;
      case 2:
        return Colors.brown.shade300;
      default:
        return Colors.grey.shade100;
    }
  }
}