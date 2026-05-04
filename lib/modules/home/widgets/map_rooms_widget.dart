import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../models/room_model.dart';
import '../../../core/config/colors.dart';

class MapRoomsWidget extends StatelessWidget {
  final List<RoomModel> rooms;

  const MapRoomsWidget({super.key, required this.rooms});

  @override
  Widget build(BuildContext context) {
    if (rooms.isEmpty) return const SizedBox.shrink();

    // Center map around the first room
    final center = LatLng(rooms.first.latitude, rooms.first.longitude);

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 12.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.rental_app',
        ),
        MarkerLayer(
          markers: rooms.map((room) {
            return Marker(
              point: LatLng(room.latitude, room.longitude),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () {
                  context.push('/room_detail', extra: room);
                },
                child: const Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
