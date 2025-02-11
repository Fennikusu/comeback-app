// lib/repository/shop_repository.dart
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../models/shop_item.dart';

class ShopRepository {
  static const String baseUrl = 'http://192.168.1.12/api/public';

  Future<Map<String, List<ShopItem>>> getAllItems() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/shop/items?user_id=1'));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          'profile_pictures': _parseItems(data['profile_pictures']),
          'banners': _parseItems(data['banners']),
          'titles': _parseItems(data['titles']),
        };
      }
      throw Exception('Failed to load items: ${response.statusCode}');
    } catch (e) {
      print('Error getting items: $e');
      throw Exception('Failed to load items: $e');
    }
  }

  List<ShopItem> _parseItems(dynamic items) {
    if (items == null || !(items is List)) return [];
    return (items as List).map((item) => ShopItem.fromJson(item)).toList();
  }

  Future<ShopItem> createItem(
      PlatformFile file, String name, String type, int price) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/assets/upload'));

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
        ),
      );

      request.fields
          .addAll({'name': name, 'type': type, 'price': price.toString()});

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success']) {
          final asset = responseData['asset'];
          return ShopItem(
            id: asset['id'].toString(),
            name: name,
            type: type,
            price: price,
            asset: Asset(filePath: asset['file_path']),
          );
        }
      }
      throw Exception(
          'Failed to create item: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('Error creating item: $e');
      rethrow;
    }
  }

  Future<ShopItem> updateItem(String id, String name, int price) async {
    final response = await http.put(
      Uri.parse('$baseUrl/shop/items/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name, 'price': price, 'user_id': '1'}),
    );

    if (response.statusCode == 200) {
      return ShopItem.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to update item');
  }

  Future<void> deleteItem(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/shop/items/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'user_id': '1'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete item');
    }
  }
}
