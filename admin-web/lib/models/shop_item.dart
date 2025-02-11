// lib/models/shop_item.dart
class Asset {
  final String filePath;

  Asset({required this.filePath});

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(filePath: json['file_path']);
  }
}

class ShopItem {
  final String id;
  final String name;
  final String type;
  final int price;
  final bool isUnlocked;
  final Asset? asset;

  ShopItem({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    this.isUnlocked = false,
    this.asset,
  });

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      id: json['id'].toString(),
      name: json['name'],
      type: json['type'],
      price: json['price'] is int
          ? json['price']
          : int.parse(json['price'].toString()),
      isUnlocked: json['is_unlocked'] == true,
      asset: json['asset'] != null ? Asset.fromJson(json['asset']) : null,
    );
  }
}
