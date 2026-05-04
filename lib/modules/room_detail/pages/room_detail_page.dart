import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../home/models/room_model.dart';
import '../../../core/config/colors.dart';
import '../../profile/providers/user_provider.dart';

class RoomDetailPage extends StatelessWidget {
  final RoomModel room;

  const RoomDetailPage({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.9),
            child: IconButton(
              icon: const Icon(
                LucideIcons.arrowLeft,
                color: AppColors.textPrimary,
                size: 20,
              ),
              onPressed: () => context.pop(),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Header
            SizedBox(
              height: 300,
              width: double.infinity,
              child: PageView.builder(
                itemCount: room.imageUrls.length,
                itemBuilder: (context, index) {
                  Widget imageWidget = CachedNetworkImage(
                    imageUrl: room.imageUrls[index],
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: AppColors.divider),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.divider,
                      child: const Icon(LucideIcons.imageOff),
                    ),
                  );

                  if (index == 0) {
                    imageWidget = Hero(
                      tag: 'room_image_${room.id}',
                      child: imageWidget,
                    );
                  }

                  return GestureDetector(
                    onTap: () {
                      _showFullScreenGallery(context, room.imageUrls, index);
                    },
                    child: imageWidget,
                  );
                },
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          room.title,
                          style: Theme.of(
                            context,
                          ).textTheme.displayLarge?.copyWith(fontSize: 24),
                        ),
                      ),
                      Text(
                        '฿${room.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.mapPin,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        room.locationName,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    room.description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Amenities',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: room.amenities
                        .map((amenity) => _buildAmenityItem(amenity))
                        .toList(),
                  ),
                  const SizedBox(height: 32),

                  // Reviews Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reviews',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.star,
                            color: Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            room.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Text(
                            ' (24 reviews)',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildReviewCard(
                    'John Doe',
                    'Great place! Very clean and near the station.',
                    5,
                  ),
                  const SizedBox(height: 12),
                  _buildReviewCard(
                    'Sarah Smith',
                    'The host was very accommodating. Highly recommended.',
                    4.5,
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Location',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 200,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(room.latitude, room.longitude),
                          initialZoom: 15.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.rental_app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(room.latitude, room.longitude),
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  LucideIcons.mapPin,
                                  color: AppColors.accent,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 100), // Padding for bottom bar
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    LucideIcons.messageCircle,
                    color: AppColors.primary,
                  ),
                  onPressed: () => _showContactSheet(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final isLogged = context.read<UserProvider>().isLoggedIn;
                    if (isLogged) {
                      context.push('/booking', extra: room);
                    } else {
                      context.push('/login');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullScreenGallery(
    BuildContext context,
    List<String> imageUrls,
    int initialIndex,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: imageUrls[index],
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(LucideIcons.imageOff, color: Colors.white),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAmenityItem(String amenity) {
    IconData icon;
    final lower = amenity.toLowerCase();
    if (lower.contains('wifi') || lower.contains('internet')) {
      icon = LucideIcons.wifi;
    } else if (lower.contains('ac') || lower.contains('air')) {
      icon = LucideIcons.wind;
    } else if (lower.contains('pool')) {
      icon = LucideIcons.waves;
    } else if (lower.contains('gym') || lower.contains('fitness')) {
      icon = LucideIcons.dumbbell;
    } else if (lower.contains('park')) {
      icon = LucideIcons.car;
    } else if (lower.contains('kitchen')) {
      icon = LucideIcons.chefHat;
    } else if (lower.contains('laundry') || lower.contains('washer')) {
      icon = LucideIcons.shirt;
    } else if (lower.contains('pet')) {
      icon = LucideIcons.dog;
    } else {
      icon = LucideIcons.checkCircle2;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            amenity,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(String name, String comment, double rating) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Text(
                  name[0],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      '1 week ago',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(LucideIcons.star, color: Colors.orange, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    rating.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(comment, style: const TextStyle(color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  void _showContactSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.secondary,
                  child: Icon(
                    LucideIcons.userCheck,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Contact Landlord',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Usually responds within an hour',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.phone, color: Colors.green),
                  ),
                  title: const Text('Phone Call'),
                  subtitle: const Text('+66 81 234 5678'),
                  trailing: const Icon(LucideIcons.chevronRight),
                  onTap: () async {
                    Navigator.pop(context);
                    final uri = Uri.parse('tel:+66812345678');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.messageSquare,
                      color: Colors.blue,
                    ),
                  ),
                  title: const Text('Line / Message'),
                  subtitle: const Text('Line ID: landlord_rent'),
                  trailing: const Icon(LucideIcons.chevronRight),
                  onTap: () async {
                    Navigator.pop(context);
                    final uri = Uri.parse('https://line.me/ti/p/~landlord_rent');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.messageCircle,
                      color: AppColors.primary,
                    ),
                  ),
                  title: const Text('In-App Chat'),
                  subtitle: const Text('Message directly inside the app'),
                  trailing: const Icon(LucideIcons.chevronRight),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/chat', extra: {
                      'landlordName': 'Landlord',
                      'roomTitle': room.title,
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
