import 'package:equatable/equatable.dart';

/// Domain Entity
class StorageItem extends Equatable {
  final String filename;
  final String originalName;
  final String publicUrl;
  final String uploadUrl;
  final String? state;

  const StorageItem({
    required this.filename,
    required this.originalName,
    required this.publicUrl,
    required this.uploadUrl,
    this.state,
  });

  @override
  List<Object?> get props => [filename, originalName, publicUrl, uploadUrl, state];
}

/// API Model
class StorageItemApiModel {
  final String filename;
  final String originalName;
  final String publicUrl;
  final String uploadUrl;
  final String? state;

  const StorageItemApiModel({
    required this.filename,
    required this.originalName,
    required this.publicUrl,
    required this.uploadUrl,
    this.state,
  });

  factory StorageItemApiModel.fromJson(Map<String, dynamic> json) {
    return StorageItemApiModel(
      filename: json['filename'] as String? ?? '',
      originalName: json['original_name'] as String? ?? '',
      publicUrl: json['public_url'] as String? ?? '',
      uploadUrl: json['upload_url'] as String? ?? '',
      state: json['state'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
      'original_name': originalName,
      'public_url': publicUrl,
      'upload_url': uploadUrl,
      'state': state,
    };
  }
}

/// Mapper
extension StorageItemApiMapper on StorageItemApiModel {
  StorageItem toDomain() {
    return StorageItem(
      filename: filename,
      originalName: originalName,
      publicUrl: publicUrl,
      uploadUrl: uploadUrl,
      state: state,
    );
  }
}
