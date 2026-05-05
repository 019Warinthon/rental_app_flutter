class LandmarkModel {
  final String name;
  final String distance;

  LandmarkModel({required this.name, required this.distance});

  factory LandmarkModel.fromJson(Map<String, dynamic> json) {
    return LandmarkModel(
      name: json['name'] as String? ?? '',
      distance: json['distance'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'distance': distance,
  };
}

class RoomModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final double dailyRate;
  final String roomSize;
  final String roomLayout;
  final String locationName;
  final String province;
  final double latitude;
  final double longitude;
  final List<String> imageUrls;
  final List<String> amenities;
  final String type; // 'Apartment', 'Studio', 'Dormitory', 'Penthouse', 'House'
  final double rating;
  
  final bool isAvailable;
  final int depositMonths;
  final int advanceMonths;
  final String waterRate;
  final String electricityRate;
  final String ownerPhone;
  final String ownerLineId;
  final bool isVerified;
  final String? ownerId;
  final List<LandmarkModel> landmarks;

  RoomModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.dailyRate = 0,
    this.roomSize = '',
    this.roomLayout = 'Studio',
    required this.locationName,
    this.province = '',
    required this.latitude,
    required this.longitude,
    required this.imageUrls,
    required this.amenities,
    this.type = 'Apartment',
    this.rating = 4.5,
    this.isAvailable = true,
    this.depositMonths = 1,
    this.advanceMonths = 1,
    this.waterRate = '',
    this.electricityRate = '',
    this.ownerPhone = '',
    this.ownerLineId = '',
    this.isVerified = false,
    this.ownerId,
    this.landmarks = const [],
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    var landmarksList = <LandmarkModel>[];
    if (json['landmarks'] != null) {
      json['landmarks'].forEach((v) {
        landmarksList.add(LandmarkModel.fromJson(v));
      });
    }

    return RoomModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      dailyRate: (json['dailyRate'] as num?)?.toDouble() ?? 0,
      roomSize: json['roomSize'] as String? ?? '',
      roomLayout: json['roomLayout'] as String? ?? 'Studio',
      locationName: json['locationName'] as String,
      province: json['province'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      amenities: List<String>.from(json['amenities'] ?? []),
      type: json['type'] as String? ?? 'Apartment',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      isAvailable: json['isAvailable'] as bool? ?? true,
      depositMonths: json['depositMonths'] as int? ?? 1,
      advanceMonths: json['advanceMonths'] as int? ?? 1,
      waterRate: json['waterRate'] as String? ?? '',
      electricityRate: json['electricityRate'] as String? ?? '',
      ownerPhone: json['ownerPhone'] as String? ?? '',
      ownerLineId: json['ownerLineId'] as String? ?? '',
      isVerified: json['isVerified'] as bool? ?? false,
      ownerId: json['ownerId'] as String?,
      landmarks: landmarksList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'dailyRate': dailyRate,
      'roomSize': roomSize,
      'roomLayout': roomLayout,
      'locationName': locationName,
      'province': province,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrls': imageUrls,
      'amenities': amenities,
      'type': type,
      'isAvailable': isAvailable,
      'depositMonths': depositMonths,
      'advanceMonths': advanceMonths,
      'waterRate': waterRate,
      'electricityRate': electricityRate,
      'ownerPhone': ownerPhone,
      'ownerLineId': ownerLineId,
      'ownerId': ownerId,
      'landmarks': landmarks.map((l) => l.toJson()).toList(),
    };
  }
}
