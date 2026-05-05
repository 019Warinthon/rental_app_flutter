import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageCompressor {
  /// ฟังก์ชันสำหรับบีบอัดรูปภาพให้เล็กลงก่อนอัพโหลด
  /// [file] คือไฟล์ต้นฉบับ
  /// [quality] คือคุณภาพ (0-100), ปกติ 70-80 ก็เพียงพอและชัดอยู่ครับ
  static Future<File?> compressImage(File file, {int quality = 80}) async {
    try {
      // 1. หาที่เก็บไฟล์ชั่วคราว
      final tempDir = await getTemporaryDirectory();
      final String targetPath = p.join(
        tempDir.path,
        "${DateTime.now().millisecondsSinceEpoch}_compressed.jpg",
      );

      // 2. เริ่มการบีบอัด
      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        // ปรับขนาดความกว้างสูงสุดให้ไม่เกิน 1920px (Full HD) เพื่อประหยัดพื้นที่
        minWidth: 1920,
        minHeight: 1080,
      );

      if (result == null) return null;

      return File(result.path);
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }

  /// ฟังก์ชันสำหรับบีบอัดรูปหลายรูปพร้อมกัน
  static Future<List<File>> compressMultipleImages(List<File> files) async {
    List<File> compressedFiles = [];
    for (var file in files) {
      final compressed = await compressImage(file);
      if (compressed != null) {
        compressedFiles.add(compressed);
      }
    }
    return compressedFiles;
  }
}
