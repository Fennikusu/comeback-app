// lib/models/asset.dart

enum AssetType { profile_picture, banner, title }

class Asset {
  final int id;
  final String fileName;
  final String filePath;
  final AssetType type;
  final String mimeType;
  final int fileSize;
  final DateTime uploadDate;
  final int? uploadedBy;

  Asset({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.type,
    required this.mimeType,
    required this.fileSize,
    required this.uploadDate,
    this.uploadedBy,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'],
      fileName: json['file_name'],
      filePath: json['file_path'],
      type: AssetType.values.firstWhere(
        (e) => e.toString().split('.').last == json['file_type'],
        orElse: () => AssetType.profile_picture,
      ),
      mimeType: json['mime_type'],
      fileSize: json['file_size'],
      uploadDate: DateTime.parse(json['upload_date']),
      uploadedBy: json['uploaded_by'],
    );
  }
}
