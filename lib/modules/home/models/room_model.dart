class RoomModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String locationName;
  final double latitude;
  final double longitude;
  final List<String> imageUrls;
  final List<String> amenities;
  final String type; // 'Apartment', 'Studio', 'Dormitory', 'Penthouse'
  final double rating;

  RoomModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.imageUrls,
    required this.amenities,
    this.type = 'Apartment',
    this.rating = 4.5,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      locationName: json['locationName'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      amenities: List<String>.from(json['amenities'] ?? []),
      type: json['type'] as String? ?? 'Apartment',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
    );
  }
}
