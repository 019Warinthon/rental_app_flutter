import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../../home/models/room_model.dart';

class BookingProvider extends ChangeNotifier {
  final List<BookingModel> _bookings = [];
  bool _isLoading = false;

  List<BookingModel> get bookings => List.unmodifiable(_bookings);
  bool get isLoading => _isLoading;

  Future<bool> createBooking({
    required RoomModel room,
    required DateTime checkIn,
    required DateTime checkOut,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      final nights = checkOut.difference(checkIn).inDays;
      final totalPrice = room.price * nights;

      final booking = BookingModel(
        id: 'BK${DateTime.now().millisecondsSinceEpoch}',
        room: room,
        checkIn: checkIn,
        checkOut: checkOut,
        totalPrice: totalPrice,
        status: BookingStatus.confirmed,
        createdAt: DateTime.now(),
      );

      _bookings.insert(0, booking);
      return true;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) return;

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final booking = _bookings[index];
    _bookings[index] = BookingModel(
      id: booking.id,
      room: booking.room,
      checkIn: booking.checkIn,
      checkOut: booking.checkOut,
      totalPrice: booking.totalPrice,
      status: BookingStatus.cancelled,
      createdAt: booking.createdAt,
    );

    _isLoading = false;
    notifyListeners();
  }
}
