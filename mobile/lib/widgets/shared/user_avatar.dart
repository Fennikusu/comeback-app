// lib/widgets/shared/user_avatar.dart
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../config/constants.dart';

class UserAvatar extends StatelessWidget {
  final User user;
  final double radius;
  final VoidCallback? onTap;

  const UserAvatar({
    Key? key,
    required this.user,
    this.radius = 20,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).scaffoldBackgroundColor,
            width: 2,
          ),
        ),
        child: CircleAvatar(
          radius: radius,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          backgroundImage: user.profilePicture != null && user.profilePicture != '1'
              ? NetworkImage('${AppConstants.baseApiUrl}/uploads/profile_pictures/${user.profilePicture}')
              : null,
          child: _buildPlaceholder(context),
        ),
      ),
    );
  }

  ImageProvider? _getProfileImage() {
    if (user.profilePicture.isNotEmpty && user.profilePicture != '1') {
      // Utilise le chemin complet de l'API
      final imageUrl = '${AppConstants.baseApiUrl}/uploads/profile_pictures/${user.profilePicture}';
      return NetworkImage(imageUrl);
    }
    return null;
  }

  Widget? _buildPlaceholder(BuildContext context) {
    if (user.profilePicture.isEmpty || user.profilePicture == '1') {
      return Text(
        user.pseudo.substring(0, 1).toUpperCase(),
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      );
    }
    return null;
  }
}