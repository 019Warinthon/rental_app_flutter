import 'dart:io';
import 'dart:typed_data';
import '../models/storage_item.dart';

abstract class IStorageService {
  /// ขอ Presigned URLs จาก Server เพื่อเตรียมอัปโหลดไฟล์
  Future<List<StorageItem>> getPresignedUrls({
    required List<String> filenames,
    required String state,
  });

  /// อัปโหลดไฟล์จาก File object ไปยัง Presigned URL
  Future<void> uploadFile({
    required String uploadUrl,
    required File file,
    String contentType = 'image/jpeg',
  });

  /// อัปโหลดไฟล์จาก Bytes ไปยัง Presigned URL
  Future<void> uploadFileBytes({
    required String uploadUrl,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  });
}
