import 'package:flutter/material.dart';
import '../../home/models/room_model.dart';
import '../../../core/storage/app_storage.dart';

class FavoritesProvider with ChangeNotifier {
  final List<RoomModel> _favorites = [];
  bool _loaded = false;

  List<RoomModel> get favorites => List.unmodifiable(_favorites);

  bool isFavorite(String roomId) {
    return _favorites.any((room) => room.id == roomId);
  }

  /// Call this once rooms are available (e.g., after HomeProvider fetches).
  /// Re-hydrates favorites from disk using saved IDs.
  Future<void> loadFromDisk(List<RoomModel> availableRooms) async {
    if (_loaded) return;
    _loaded = true;
    final savedIds = await AppStorage.getFavoriteIds();
    if (savedIds.isEmpty) return;
    final restored = availableRooms.where((r) => savedIds.contains(r.id));
    _favorites.addAll(restored);
    notifyListeners();
  }

  Future<void> toggleFavorite(RoomModel room) async {
    if (isFavorite(room.id)) {
      _favorites.removeWhere((r) => r.id == room.id);
    } else {
      _favorites.add(room);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final ids = _favorites.map((r) => r.id).toList();
    await AppStorage.saveFavoriteIds(ids);
  }
}
