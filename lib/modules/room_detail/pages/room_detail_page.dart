import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../home/models/room_model.dart';
import '../../home/models/review_model.dart';
import '../../../core/config/colors.dart';
import '../../../core/config/typography.dart';
import '../../profile/providers/user_provider.dart';
import '../../main/providers/favorites_provider.dart';
import '../../home/providers/home_provider.dart';
import '../providers/review_provider.dart';
import '../../chat/providers/chat_provider.dart';

class RoomDetailPage extends StatelessWidget {
  final RoomModel room;

  const RoomDetailPage({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    // Fetch reviews on enter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewProvider>().fetchReviews(room.id);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Use SliverAppBar for native dark transition when scrolled
              SliverAppBar(
                expandedHeight: 400,
                pinned: true,
                stretch: true,
                backgroundColor: AppColors.primary,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  Consumer<FavoritesProvider>(
                    builder: (context, favProvider, child) {
                      final isFav = favProvider.isFavorite(room.id);
                      return IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : Colors.white,
                        ),
                        onPressed: () {
                          final userProvider = context.read<UserProvider>();
                          if (!userProvider.isLoggedIn) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('กรุณาเข้าสู่ระบบเพื่อบันทึกห้องโปรด')),
                            );
                            return;
                          }
                          favProvider.toggleFavorite(room, userProvider.user.id);
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.share2, color: Colors.white),
                    onPressed: () {},
                  ),
                  // แสดงเมนูแก้ไข/ลบ เฉพาะเจ้าของที่พัก
                  Builder(builder: (ctx) {
                    final userProvider = ctx.watch<UserProvider>();
                    final isOwner = userProvider.isLoggedIn &&
                        room.ownerId != null &&
                        userProvider.user.id == room.ownerId;

                    if (!isOwner) return const SizedBox.shrink();

                    return PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (value) {
                        if (value == 'edit') {
                          context.push('/edit-property', extra: room);
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(context, room);
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('แก้ไขประกาศ')])),
                        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 20, color: Colors.red), SizedBox(width: 8), Text('ลบประกาศ', style: TextStyle(color: Colors.red))])),
                      ],
                    );
                  }),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode:
                      CollapseMode.pin, // Prevents image from shrinking weirdly
                  title: LayoutBuilder(
                    builder: (context, constraints) {
                      // Only show title when collapsed
                      final isCollapsed =
                          constraints.biggest.height <=
                          kToolbarHeight +
                              MediaQuery.of(context).padding.top +
                              10;
                      return AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isCollapsed ? 1.0 : 0.0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              room.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '฿${room.price.toStringAsFixed(0)} - ${room.locationName}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      PageView.builder(
                        itemCount: room.imageUrls.length,
                        itemBuilder: (context, index) {
                          return CachedNetworkImage(
                            imageUrl: room.imageUrls[index],
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                      // Top shadow for back button visibility
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black45,
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black38,
                            ],
                            stops: [0.0, 0.3, 0.7, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 140),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badges
                      Row(
                        children: [
                          _buildBadge(
                            LucideIcons.shieldCheck,
                            'ตรวจสอบแล้ว',
                            Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          _buildBadge(
                            LucideIcons.layout,
                            room.roomLayout,
                            Colors.purple,
                          ),
                          const SizedBox(width: 8),
                          _buildBadge(
                            LucideIcons.home,
                            room.type,
                            AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Title and Price Summary
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  room.title,
                                  style: AppTypography.fontTitleLargeProminent(),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      LucideIcons.mapPin,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      room.locationName,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  LucideIcons.star,
                                  color: Colors.orange,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  room.rating.toString(),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Premium Pricing Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              'ราคาเช่า',
                              '฿${room.price.toStringAsFixed(0)}',
                              '/เดือน',
                              LucideIcons.banknote,
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (room.dailyRate > 0) ...[
                            Expanded(
                              child: _buildInfoCard(
                                'รายวัน',
                                '฿${room.dailyRate.toStringAsFixed(0)}',
                                '/วัน',
                                LucideIcons.calendarDays,
                              ),
                            ),
                          ] else ...[
                            Expanded(
                              child: _buildInfoCard(
                                'เงินมัดจำ',
                                '${room.depositMonths}',
                                'เดือน',
                                LucideIcons.lock,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              'ขนาดห้อง',
                              room.roomSize.isEmpty ? '-' : room.roomSize,
                              'ตร.ม.',
                              LucideIcons.maximize,
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (room.dailyRate > 0)
                            Expanded(
                              child: _buildInfoCard(
                                'เงินมัดจำ',
                                '${room.depositMonths}',
                                'เดือน',
                                LucideIcons.lock,
                              ),
                            )
                          else
                            const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 32),

                      _buildSectionTitle('สิ่งอำนวยความสะดวก'),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: room.amenities
                            .map((a) => _buildAmenityBadge(a))
                            .toList(),
                      ),
                      const SizedBox(height: 32),

                      _buildSectionTitle('รายละเอียดที่พัก'),
                      Text(
                        room.description,
                        style: AppTypography.fontBodyLarge(
                          color: Colors.grey.shade700,
                        ).copyWith(height: 1.7),
                      ),
                      const SizedBox(height: 32),

                      _buildSectionTitle('เงื่อนไขการเช่า'),
                      _buildRuleRow(
                        LucideIcons.calendarCheck,
                        'จ่ายล่วงหน้า',
                        '${room.advanceMonths} เดือน',
                      ),
                      _buildRuleRow(
                        LucideIcons.droplets,
                        'ค่าน้ำ',
                        room.waterRate,
                      ),
                      _buildRuleRow(
                        LucideIcons.zap,
                        'ค่าไฟ',
                        room.electricityRate,
                      ),
                      const SizedBox(height: 32),

                      _buildSectionTitle('ตำแหน่งที่ตั้ง'),
                      _buildMapView(room),
                      const SizedBox(height: 32),

                      // Reviews
                      _buildReviewHeader(context),
                      const SizedBox(height: 16),
                      _buildDynamicReviews(context),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomActionBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    String unit,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: AppTypography.fontTitleMediumProminent(),
      ),
    );
  }

  Widget _buildAmenityBadge(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade100),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4),
        ],
      ),
      child: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  Widget _buildRuleRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView(RoomModel room) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(room.latitude, room.longitude),
            initialZoom: 15.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(room.latitude, room.longitude),
                  width: 50,
                  height: 50,
                  child: const Icon(
                    LucideIcons.mapPin,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'รีวิวและคะแนน',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () => _showReviewSheet(context),
          child: const Text(
            'เขียนรีวิว',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicReviews(BuildContext context) {
    return Consumer<ReviewProvider>(
      builder: (context, provider, _) {
        final reviews = provider.getReviews(room.id);
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (reviews.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'ยังไม่มีรีวิว',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }
        return Column(
          children: reviews.map((r) => _ReviewCard(review: r)).toList(),
        );
      },
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 34),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              _buildActionIcon(LucideIcons.messageCircle, () async {
                final userProvider = context.read<UserProvider>();
                if (!userProvider.isLoggedIn) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('กรุณาเข้าสู่ระบบเพื่อพูดคุย')),
                  );
                  return;
                }

                if (room.ownerId == null) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ไม่พบข้อมูลเจ้าของหอ')),
                  );
                  return;
                }

                final chatProvider = context.read<ChatProvider>();
                await chatProvider.openChat(room.id, room.ownerId!);
                
                if (context.mounted) {
                  context.push('/chat');
                }
              }),
              const SizedBox(width: 12),
              _buildActionIcon(
                LucideIcons.phone,
                () => launchUrl(Uri.parse('tel:${room.ownerPhone}')),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.push('/booking', extra: room),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    fixedSize: const Size.fromHeight(58),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'จองห้องพักตอนนี้',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, VoidCallback onTap) {
    return Container(
      height: 58,
      width: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Center(child: Icon(icon, color: AppColors.primary, size: 24)),
        ),
      ),
    );
  }

  void _showReviewSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => _AddReviewSheet(roomId: room.id),
    );
  }

  void _showDeleteConfirmation(BuildContext context, RoomModel room) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('ยืนยันการลบ'),
          ],
        ),
        content: Text('คุณต้องการลบ "${room.title}" ใช่หรือไม่?\nข้อมูลทั้งหมดจะถูกลบอย่างถาวร'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<HomeProvider>();
              final success = await provider.deleteProperty(room.id);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ลบประกาศเรียบร้อยแล้ว'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('เกิดข้อผิดพลาดในการลบ'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  review.userName.isNotEmpty ? review.userName[0] : 'U',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.star,
                      color: Colors.orange,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      review.rating.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: const TextStyle(color: Colors.black87, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _AddReviewSheet extends StatefulWidget {
  final String roomId;
  const _AddReviewSheet({required this.roomId});

  @override
  State<_AddReviewSheet> createState() => _AddReviewSheetState();
}

class _AddReviewSheetState extends State<_AddReviewSheet> {
  final _commentController = TextEditingController();
  double _rating = 5.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 32,
        right: 32,
        top: 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'ให้คะแนนความพึงพอใจ',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => IconButton(
                icon: Icon(
                  LucideIcons.star,
                  color: index < _rating ? Colors.orange : Colors.grey.shade300,
                  size: 40,
                ),
                onPressed: () => setState(() => _rating = index + 1.0),
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'บอกเล่าความประทับใจ...',
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: () async {
                final name = context.read<UserProvider>().user.name;
                await context.read<ReviewProvider>().addReview(
                  widget.roomId,
                  name,
                  _rating,
                  _commentController.text,
                );
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'ส่งรีวิว',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
