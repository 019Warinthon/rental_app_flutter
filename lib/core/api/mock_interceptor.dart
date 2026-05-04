import 'package:dio/dio.dart';

class MockInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.path == '/rooms') {
      await Future.delayed(const Duration(milliseconds: 800));

      final mockData = [
        {
          'id': '1',
          'title': 'Modern Cozy Apartment',
          'description':
              'A beautiful modern apartment in the city center with amazing city views, great transit access, and contemporary furnishings throughout.',
          'price': 15000.0,
          'locationName': 'Sukhumvit, Bangkok',
          'latitude': 13.736717,
          'longitude': 100.523186,
          'type': 'Apartment',
          'rating': 4.8,
          'imageUrls': [
            'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&q=80&w=800',
            'https://images.unsplash.com/photo-1502672260266-1c1de2d93688?auto=format&fit=crop&q=80&w=800',
            'https://images.unsplash.com/photo-1484154218962-a197022b5858?auto=format&fit=crop&q=80&w=800',
          ],
          'amenities': ['Wi-Fi', 'Air Conditioning', 'Gym', 'Pool', 'Parking'],
        },
        {
          'id': '2',
          'title': 'Minimalist Studio Dorm',
          'description':
              'Perfect for students or solo workers. A quiet environment with great community facilities, clean shared spaces, and 24/7 security.',
          'price': 6500.0,
          'locationName': 'Phaya Thai, Bangkok',
          'latitude': 13.7563,
          'longitude': 100.5018,
          'type': 'Dormitory',
          'rating': 4.3,
          'imageUrls': [
            'https://images.unsplash.com/photo-1536376072261-38c75010e6c9?auto=format&fit=crop&q=80&w=800',
            'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?auto=format&fit=crop&q=80&w=800',
          ],
          'amenities': ['Wi-Fi', 'Laundry', 'Security Camera', 'Common Room'],
        },
        {
          'id': '3',
          'title': 'Luxury Penthouse Suite',
          'description':
              'Spacious penthouse with premium furnishings, a private balcony with 360-degree city views, and top-tier building amenities.',
          'price': 45000.0,
          'locationName': 'Thong Lo, Bangkok',
          'latitude': 13.7307,
          'longitude': 100.5827,
          'type': 'Penthouse',
          'rating': 4.9,
          'imageUrls': [
            'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd?auto=format&fit=crop&q=80&w=800',
            'https://images.unsplash.com/photo-1549294413-26f195200c16?auto=format&fit=crop&q=80&w=800',
          ],
          'amenities': [
            'Wi-Fi',
            'Air Conditioning',
            'Gym',
            'Pool',
            'Parking',
            'Concierge',
            'Balcony'
          ],
        },
        {
          'id': '4',
          'title': 'Compact Studio in Silom',
          'description':
              'Smart studio with efficient layout, modern kitchen, and great location near BTS Silom. Ideal for young professionals.',
          'price': 9500.0,
          'locationName': 'Silom, Bangkok',
          'latitude': 13.7233,
          'longitude': 100.5295,
          'type': 'Studio',
          'rating': 4.4,
          'imageUrls': [
            'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format&fit=crop&q=80&w=800',
            'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?auto=format&fit=crop&q=80&w=800',
          ],
          'amenities': ['Wi-Fi', 'Air Conditioning', 'Kitchenette', 'Elevator'],
        },
        {
          'id': '5',
          'title': 'Student Dorm Near University',
          'description':
              'Affordable dormitory right next to Chulalongkorn University. Includes meals, cleaning service, and a study lounge.',
          'price': 4500.0,
          'locationName': 'Sam Yan, Bangkok',
          'latitude': 13.7353,
          'longitude': 100.5261,
          'type': 'Dormitory',
          'rating': 4.1,
          'imageUrls': [
            'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?auto=format&fit=crop&q=80&w=800',
          ],
          'amenities': ['Wi-Fi', 'Meals Included', 'Cleaning', 'Study Lounge', 'Laundry'],
        },
        {
          'id': '6',
          'title': 'Riverside Serviced Apartment',
          'description':
              'Elegant serviced apartment with Chao Phraya river views, fully furnished, weekly housekeeping, and concierge service.',
          'price': 28000.0,
          'locationName': 'Bang Rak, Bangkok',
          'latitude': 13.7239,
          'longitude': 100.5125,
          'type': 'Apartment',
          'rating': 4.7,
          'imageUrls': [
            'https://images.unsplash.com/photo-1484154218962-a197022b5858?auto=format&fit=crop&q=80&w=800',
            'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&q=80&w=800',
          ],
          'amenities': [
            'Wi-Fi',
            'Air Conditioning',
            'Housekeeping',
            'Concierge',
            'River View',
            'Pool'
          ],
        },
        {
          'id': '7',
          'title': 'Zen Studio Hideaway',
          'description':
              'Minimalist Japanese-inspired studio in a quiet alley. Perfect for those seeking peace, with a zen garden and meditation space.',
          'price': 11000.0,
          'locationName': 'Ari, Bangkok',
          'latitude': 13.7742,
          'longitude': 100.5438,
          'type': 'Studio',
          'rating': 4.6,
          'imageUrls': [
            'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?auto=format&fit=crop&q=80&w=800',
            'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format&fit=crop&q=80&w=800',
          ],
          'amenities': ['Wi-Fi', 'Air Conditioning', 'Garden', 'Bicycle', 'Library'],
        },
        {
          'id': '8',
          'title': 'Sky High Penthouse',
          'description':
              'Ultra-luxury penthouse on the 45th floor with infinity pool, private chef service, and panoramic views of Bangkok.',
          'price': 85000.0,
          'locationName': 'Sathorn, Bangkok',
          'latitude': 13.7212,
          'longitude': 100.5393,
          'type': 'Penthouse',
          'rating': 5.0,
          'imageUrls': [
            'https://images.unsplash.com/photo-1549294413-26f195200c16?auto=format&fit=crop&q=80&w=800',
            'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd?auto=format&fit=crop&q=80&w=800',
          ],
          'amenities': [
            'Wi-Fi',
            'Infinity Pool',
            'Private Chef',
            'Butler Service',
            'Helipad',
            'Gym',
            'Sauna'
          ],
        },
      ];

      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {'data': mockData},
        ),
      );
    }

    return handler.next(options);
  }
}
