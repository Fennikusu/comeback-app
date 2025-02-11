// lib/services/asset_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import '../models/asset.dart';
import '../config/api_config.dart';

class AssetService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<Asset> uploadAssetWeb(
      Uint8List bytes, String fileName, AssetType type) async {
    final url = Uri.parse('$baseUrl/assets/upload');

    var request = http.MultipartRequest('POST', url);

    // Ajouter le fichier
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
      ),
    );

    // Ajouter le type
    request.fields['type'] = type.toString().split('.').last;

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final jsonResponse = json.decode(responseBody);

    if (response.statusCode == 200 && jsonResponse['success']) {
      return Asset.fromJson(jsonResponse['asset']);
    } else {
      throw Exception(jsonResponse['message'] ?? 'Failed to upload asset');
    }
  }

  Future<List<Asset>> getAssetsByType(AssetType type) async {
    final response = await http.get(
      Uri.parse('$baseUrl/assets?type=${type.toString().split('.').last}'),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success']) {
        return (jsonResponse['assets'] as List)
            .map((json) => Asset.fromJson(json))
            .toList();
      }
    }
    throw Exception('Failed to load assets');
  }

  Future<void> deleteAsset(int assetId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/assets/$assetId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete asset');
    }
  }

  Future<void> assignAssetToItem(int itemId, int assetId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/shop/items/asset'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'item_id': itemId,
        'asset_id': assetId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to assign asset to item');
    }
  }
}
