import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:rental_app/core/api/api_client.dart';
import 'package:rental_app/modules/images/services/i_storage_service.dart';
import 'package:rental_app/modules/images/services/service_images_storage.dart';

// เราจะสร้าง Class สำหรับจัดการการสร้าง Service ต่างๆ
// เพื่อนำไปใช้ใน MultiProvider ของ main.dart ครับ

class StorageProviders {
  // ฟังก์ชันสำหรับดึงรายการ Providers ทั้งหมดที่เกี่ยวกับ Storage
  static List<dynamic> get providers => [
    // 1. สร้าง Dio สำหรับอัพโหลด
    Provider<Dio>(
      create: (_) => Dio(),
    ),
    
    // 2. สร้าง StorageService โดยดึง ApiClient และ Dio มาใช้งาน
    ProxyProvider2<ApiClient, Dio, IStorageService>(
      update: (context, apiClient, uploadDio, _) => StorageService(
        apiClient,
        uploadDio,
      ),
    ),
  ];
}
