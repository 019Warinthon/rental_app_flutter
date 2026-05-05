import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../../home/models/room_model.dart';
import '../../../core/utils/logger.dart';
import '../services/booking_service.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService _bookingService = BookingService();
  List<BookingModel> _bookings = [];
  bool _isLoading = false;

  List<BookingModel> get bookings => List.unmodifiable(_bookings);
  bool get isLoading => _isLoading;

  /// ดึงรายการจองทั้งหมดจาก Backend
  Future<void> fetchBookings({String? userId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetchedBookings = await _bookingService.fetchBookings(userId: userId);
      _bookings = fetchedBookings;
    } catch (e) {
      Logger.error('Failed to fetch bookings', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// สร้างการจองใหม่ ส่งไป Backend
  Future<bool> createBooking({
    required RoomModel room,
    required DateTime checkIn,
    required DateTime checkOut,
    String? userId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newBooking = await _bookingService.createBooking(
        room: room,
        checkIn: checkIn,
        checkOut: checkOut,
        userId: userId,
      );

      if (newBooking != null) {
        _bookings.insert(0, newBooking);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      Logger.error('Failed to create booking', e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ยกเลิกการจอง
  Future<void> cancelBooking(String bookingId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedBooking = await _bookingService.cancelBooking(bookingId);
      if (updatedBooking != null) {
        final index = _bookings.indexWhere((b) => b.id == bookingId);
        if (index != -1) {
          _bookings[index] = updatedBooking;
        }
      }
    } catch (e) {
      Logger.error('Failed to cancel booking', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
