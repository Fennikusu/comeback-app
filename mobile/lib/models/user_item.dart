class UserItem {
  final int id;
  final String type; // 'profile_picture', 'banner', 'title'
  final String name;
  final bool isUnlocked;

  UserItem({
    required this.id,
    required this.type,
    required this.name,
    required this.isUnlocked,
  });
}