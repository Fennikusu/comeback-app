// lib/services/shop_service.dart
import 'package:file_picker/file_picker.dart';
import '../models/shop_item.dart';
import '../repository/shop_repository.dart';

class ShopService {
  final ShopRepository _repository;

  ShopService() : _repository = ShopRepository();

  Future<Map<String, List<ShopItem>>> getAllItems() async {
    final items = await _repository.getAllItems();
    return items;
  }

  Future<ShopItem> createItem(
      PlatformFile file, String name, String type, int price) async {
    return await _repository.createItem(file, name, type, price);
  }

  Future<ShopItem> updateItem(String id, String name, int price) async {
    return await _repository.updateItem(id, name, price);
  }

  Future<void> deleteItem(String id) async {
    await _repository.deleteItem(id);
  }
}
