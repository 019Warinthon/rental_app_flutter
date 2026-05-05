import '../../home/models/room_model.dart';

enum BookingStatus { pending, confirmed, cancelled, completed }

class BookingModel {
  final String id;
  final RoomModel room;
  final DateTime checkIn;
  final DateTime checkOut;
  final double totalPrice;
  final BookingStatus status;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.room,
    required this.checkIn,
    required this.checkOut,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  int get nights => checkOut.difference(checkIn).inDays;

  String get statusLabel {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
    }
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      room: RoomModel.fromJson(json['room'] as Map<String, dynamic>),
      checkIn: DateTime.parse(json['checkIn'] as String),
      checkOut: DateTime.parse(json['checkOut'] as String),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: _parseStatus(json['status'] as String? ?? 'confirmed'),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static BookingStatus _parseStatus(String status) {
    switch (status) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'completed':
        return BookingStatus.completed;
      default:
        return BookingStatus.confirmed;
    }
  }
}
