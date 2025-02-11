// lib/views/leaderboard/widgets/global_leaderboard.dart
import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../../../config/constants.dart';

class GlobalLeaderboard extends StatelessWidget {
  final List<User> users;

  const GlobalLeaderboard({
    Key? key,
    required this.users,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Center(child: Text('Aucun joueur trouvé'));
    }

    return CustomScrollView(
      slivers: [
        // Podium pour le top 3
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildPodium(context),
          ),
        ),

        // Liste des autres joueurs
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              // On commence à partir du 4ème joueur
              final actualIndex = index + 3;
              if (actualIndex >= users.length) return null;
              final user = users[actualIndex];
              return _buildListItem(context, user, actualIndex);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPodium(BuildContext context) {
    if (users.length < 3) return const SizedBox.shrink();

    return SizedBox(
      height: 280,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Second place (left)
          if (users.length > 1)
            Positioned(
              left: 0,
              bottom: 40,
              child: _buildPodiumUser(context, users[1], 1, 200),
            ),

          // First place (center)
          Positioned(
            bottom: 60,
            child: _buildPodiumUser(context, users[0], 0, 240),
          ),

          // Third place (right)
          if (users.length > 2)
            Positioned(
              right: 0,
              bottom: 20,
              child: _buildPodiumUser(context, users[2], 2, 160),
            ),

          // Podium platforms
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildPlatform(60, Colors.grey.shade300),
                _buildPlatform(80, Colors.amber),
                _buildPlatform(40, Colors.brown.shade300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumUser(BuildContext context, User user, int rank, double height) {
    final hasProfilePicture = user.profilePictureAsset?.filePath != null;
    final hasBanner = user.bannerAsset?.filePath != null;

    return Container(
      width: 120,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Banner
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 60,
              width: double.infinity,
              child: hasBanner
                  ? Image.network(
                AppConstants.imageUrl(user.bannerAsset!.filePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
              )
                  : Container(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
            ),
          ),

          // Profile Picture
          Transform.translate(
            offset: const Offset(0, -20),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                backgroundImage: user.profilePicture != '1'
                    ? NetworkImage(AppConstants.profileImage(user.profilePicture))
                    : null,
                child: !hasProfilePicture
                    ? Text(user.pseudo[0].toUpperCase())
                    : null,
              ),
            ),
          ),

          // Rank Badge
          Transform.translate(
            offset: const Offset(0, -50),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getRankColor(rank),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '#${rank + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // User Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Text(
                  user.pseudo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (user.title != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      user.title!,
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).primaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '${user.coins} coins',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatform(double height, Color color) {
    return Container(
      width: 100,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, User user, int index) {
    final hasProfilePicture = user.profilePictureAsset?.filePath != null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              backgroundImage: user.profilePicture != '1'
                  ? NetworkImage(AppConstants.profileImage(user.profilePicture))
                  : null,
              child: !hasProfilePicture
                  ? Text(user.pseudo[0].toUpperCase())
                  : null,
            ),
          ],
        ),
        title: Text(
          user.pseudo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: user.title != null ? Text(user.title!) : null,
        trailing: Text(
          '${user.coins} coins',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
        return Colors.grey;
    }
  }
}