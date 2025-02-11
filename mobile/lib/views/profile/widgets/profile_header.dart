// lib/views/profile/widgets/profile_header.dart
import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../../../config/constants.dart';
import 'dart:developer' as dev;

class ProfileHeader extends StatelessWidget {
  final User user;
  final double? bannerHeight;
  final double avatarRadius;

  const ProfileHeader({
    Key? key,
    required this.user,
    this.bannerHeight = 120,
    this.avatarRadius = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    dev.log('=== DEBUG PROFILE HEADER ===');
    dev.log('User ID: ${user.id}');
    dev.log('Profile picture path: ${user.profilePictureAsset?.filePath}');
    dev.log('Banner path: ${user.bannerAsset?.filePath}');
    dev.log('==========================');

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Bannière
        Container(
          height: bannerHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
            image: user.bannerAsset?.filePath != null
                ? DecorationImage(
              image: NetworkImage(AppConstants.imageUrl(user.bannerAsset!.filePath)),
              fit: BoxFit.cover,
            )
                : null,
          ),
        ),

        // Informations utilisateur
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
            child: Row(
              children: [
                // Photo de profil
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: Theme.of(context).primaryColor,
                    backgroundImage: user.profilePictureAsset?.filePath != null
                        ? NetworkImage(AppConstants.imageUrl(user.profilePictureAsset!.filePath))
                        : null,
                    child: user.profilePictureAsset?.filePath == null
                        ? Text(
                      user.pseudo[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: avatarRadius * 0.8,
                        color: Colors.white,
                      ),
                    )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),

                // Pseudo et titre
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user.pseudo,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (user.title != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user.title!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}