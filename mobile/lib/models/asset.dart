// lib/models/asset.dart

class Asset {
  final String id;
  final String fileName;
  final String filePath;
  final String type;
  final String mimeType;
  final int fileSize;
  final DateTime uploadDate;
  static const String baseUrl = 'http://192.168.1.12/api/public';

  Asset({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.type,
    required this.mimeType,
    required this.fileSize,
    required this.uploadDate,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    if (json['file_path'] == null) {
      throw Exception('file_path is required');
    }

    return Asset(
      id: json['id']?.toString() ?? '',
      fileName: json['file_name'] ?? '',
      filePath: json['file_path'].toString().replaceAll('\\/', '/'),
      type: json['file_type'] ?? '',
      mimeType: json['mime_type'] ?? '',
      fileSize: json['file_size'] ?? 0,
      uploadDate: json['upload_date'] != null
          ? DateTime.parse(json['upload_date'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'file_name': fileName,
    'file_path': filePath,
    'file_type': type,
    'mime_type': mimeType,
    'file_size': fileSize,
    'upload_date': uploadDate.toIso8601String(),
  };

  String get fullUrl => '$baseUrl/$filePath';
}