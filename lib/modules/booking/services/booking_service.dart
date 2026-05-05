import '../../../core/api/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/booking_model.dart';
import '../../home/models/room_model.dart';

class BookingService {
  final ApiClient _apiClient = ApiClient();

  Future<List<BookingModel>> fetchBookings({String? userId}) async {
    try {
      final queryParams = userId != null ? {'user_id': userId} : null;
      final response = await _apiClient.get(
        '/bookings',
        queryParameters: queryParams?.cast<String, dynamic>(),
      );

      final List<dynamic> data = response['data'] ?? [];
      return data
          .where((json) => json['room'] != null) // กรองเฉพาะที่มีข้อมูลห้อง
          .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      Logger.error('BookingService.fetchBookings failed', e);
      return [];
    }
  }

  Future<BookingModel?> createBooking({
    required RoomModel room,
    required DateTime checkIn,
    required DateTime checkOut,
    String? userId,
  }) async {
    try {
      final nights = checkOut.difference(checkIn).inDays;
      final totalPrice = room.price * nights;

      final response = await _apiClient.post('/bookings', data: {
        'propertyId': room.id,
        'userId': userId,
        'checkIn': checkIn.toIso8601String(),
        'checkOut': checkOut.toIso8601String(),
        'totalPrice': totalPrice,
      });

      if (response != null && response['id'] != null) {
        return BookingModel.fromJson(response as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      Logger.error('BookingService.createBooking failed', e);
      return null;
    }
  }

  Future<BookingModel?> cancelBooking(String bookingId) async {
    try {
      final response = await _apiClient.put('/bookings/$bookingId/cancel');
      if (response != null && response['id'] != null) {
        return BookingModel.fromJson(response as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      Logger.error('BookingService.cancelBooking failed', e);
      return null;
    }
  }
}
