// lib/views/leaderboard/widgets/audacious_leaderboard.dart
import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../../../config/constants.dart';

class AudaciousLeaderboard extends StatelessWidget {
  final User? topWinner;
  final User? topLoser;

  const AudaciousLeaderboard({
    Key? key,
    this.topWinner,
    this.topLoser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (topWinner == null && topLoser == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 64,
                color: Theme.of(context).primaryColor.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Aucune donnée disponible pour le moment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Les joueurs les plus audacieux de la journée apparaîtront ici',
                style: TextStyle(
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (topWinner != null)
            _buildAudaciousCard(
              context,
              title: 'Plus gros gain du jour',
              user: topWinner!,
              isWinner: true,
            ),
          const SizedBox(height: 16),
          if (topLoser != null)
            _buildAudaciousCard(
              context,
              title: 'Plus grosse perte du jour',
              user: topLoser!,
              isWinner: false,
            ),
        ],
      ),
    );
  }

  Widget _buildAudaciousCard(BuildContext context, {
    required String title,
    required User user,
    required bool isWinner,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: Column(
        children: [
          // Banner section with gradient overlay
          SizedBox(
            height: 120,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Banner image or color
                if (user.banner != null)
                  Image.network(
                    AppConstants.bannerImage(user.banner!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: isWinner ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    ),
                  )
                else
                  Container(
                    color: isWinner ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                // Title overlay
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 4.0,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // User info and stats section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User info row
                Row(
                  children: [
                    // Avatar with border
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isWinner ? Colors.green : Colors.red,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        backgroundImage: user.profilePicture != '1'
                            ? NetworkImage(AppConstants.profileImage(user.profilePicture))
                            : null,
                        child: user.profilePicture == '1'
                            ? Text(
                          user.pseudo[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // User details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.pseudo,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (user.title != null) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                user.title!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Stats container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (isWinner ? Colors.green : Colors.red).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (isWinner ? Colors.green : Colors.red).withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Montant gagné/perdu
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isWinner ? 'Montant gagné' : 'Montant perdu',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            isWinner
                                ? '+${user.totalWin ?? 0} coins'
                                : '-${user.totalLoss ?? 0} coins',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isWinner ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(),
                      ),
                      // Solde actuel
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Solde actuel',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${user.coins} coins',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}