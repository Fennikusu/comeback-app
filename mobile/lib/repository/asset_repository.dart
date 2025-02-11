// lib/repository/asset_repository.dart
import 'dart:typed_data';
import '../models/asset.dart';
import '../core/api/api_client.dart';
import '../config/constants.dart';

class AssetRepository {
  final ApiClient _apiClient;

  AssetRepository(this._apiClient);

  Future<Asset> uploadAsset(Uint8List bytes, String fileName, String type) async {
    var uri = Uri.parse('${AppConstants.baseApiUrl}/assets/upload');
    var request = http.MultipartRequest('POST', uri);

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
      ),
    );

    request.fields['type'] = type;

    // Ajouter les headers d'autorisation si nécessaire
    var token = _apiClient.getAuthToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] && data['asset'] != null) {
        return Asset.fromJson(data['asset']);
      }
    }
    throw Exception('Failed to upload asset');
  }

  Future<List<Asset>> getAssetsByType(String type) async {
    final response = await _apiClient.get<List<dynamic>>(
      '/assets',
      queryParameters: {'type': type},
    );

    if (response.success && response.data != null) {
      return response.data!
          .map((json) => Asset.fromJson(json))
          .toList();
    }
    throw Exception('Failed to load assets');
  }

  Future<void> deleteAsset(String assetId) async {
    final response = await _apiClient.delete(
      '/assets/$assetId',
    );

    if (!response.success) {
      throw Exception('Failed to delete asset');
    }
  }
}