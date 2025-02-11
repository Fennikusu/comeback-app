// lib/models/shop_item.dart
import 'asset.dart';

class ShopItem {
  final String id;
  final String name;
  final String type;
  final int price;
  final bool isUnlocked;
  final Asset? asset;
  final String? imagePath;

  ShopItem({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    this.isUnlocked = false,
    this.asset,
    this.imagePath,
  });

  String? get displayImage {
    if (asset?.filePath != null) return 'uploads/${asset!.filePath}';
    if (imagePath != null) return 'uploads/$type/$imagePath';
    return null;
  }

  ShopItem copyWith({
    String? id,
    String? name,
    String? type,
    int? price,
    bool? isUnlocked,
    Asset? asset,
    String? imagePath,
  }) {
    return ShopItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      price: price ?? this.price,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      asset: asset ?? this.asset,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      id: json['id'].toString(),
      name: json['name'].toString(),
      type: json['type'].toString(),
      price: int.parse(json['price'].toString()),
      isUnlocked: json['is_unlocked'] == true,
      asset: json['asset'] != null ? Asset.fromJson(json['asset']) : null,
      imagePath: json['image_path'],
    );
  }
}