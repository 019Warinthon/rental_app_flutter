import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:rental_app/core/api/api_client.dart';
import '../models/storage_item.dart';
import 'i_storage_service.dart';

class StorageService implements IStorageService {
  final ApiClient _apiClient;
  final Dio _uploadDio;

  StorageService(this._apiClient, this._uploadDio);

  @override
  Future<List<StorageItem>> getPresignedUrls({
    required List<String> filenames,
    required String state,
  }) async {
    final response = await _apiClient.post(
      '/storage/presigned-urls',
      data: {'file_name': filenames, 'state': state},
    );

    // ป้องกันการเข้าถึง data ที่อาจเป็น null หรือไม่มี items
    final Map<String, dynamic> data = response['data'] ?? {};
    final List<dynamic> items = data['items'] ?? [];

    return items
        .map(
          (json) => StorageItemApiModel.fromJson(
            json as Map<String, dynamic>,
          ).toDomain(),
        )
        .toList();
  }

  @override
  Future<void> uploadFile({
    required String uploadUrl,
    required File file,
    String contentType = 'image/jpeg',
  }) async {
    try {
      final len = await file.length();

      await _uploadDio.put(
        uploadUrl,
        data: file.openRead(),
        options: Options(
          headers: {
            Headers.contentLengthHeader: len,
            HttpHeaders.contentTypeHeader: contentType,
          },
        ),
      );
    } catch (e) {
      throw Exception('Failed to upload file to storage: $e');
    }
  }

  @override
  Future<void> uploadFileBytes({
    required String uploadUrl,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    try {
      await _uploadDio.put(
        uploadUrl,
        data: bytes, // Dio handles Uint8List as binary body
        options: Options(
          headers: {
            Headers.contentLengthHeader: bytes.length,
            HttpHeaders.contentTypeHeader: contentType,
          },
        ),
      );
    } catch (e) {
      throw Exception('Failed to upload bytes to storage: $e');
    }
  }
}
