// lib/config/admin_config.dart

class AdminConfig {
  static const List<String> authorizedEmails = [
    'user1@user.com',
    'sim.dub@gmail.com',
    // Ajoutez d'autres emails admin ici
  ];

  static bool isAuthorizedAdmin(String email) {
    return authorizedEmails.contains(email.toLowerCase());
  }
}
