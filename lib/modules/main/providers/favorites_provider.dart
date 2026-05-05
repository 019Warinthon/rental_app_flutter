import 'package:flutter/material.dart';
import '../../home/models/room_model.dart';
import '../services/favorite_service.dart';

class FavoritesProvider with ChangeNotifier {
  final FavoriteService _favoriteService = FavoriteService();
  List<RoomModel> _favorites = [];
  bool _isLoading = false;
  String _currentUserId = '';

  List<RoomModel> get favorites => List.unmodifiable(_favorites);
  bool get isLoading => _isLoading;

  bool isFavorite(String roomId) {
    return _favorites.any((room) => room.id == roomId);
  }

  void updateUser(String userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      if (userId.isNotEmpty) {
        fetchFavorites(userId);
      } else {
        clearFavorites();
      }
    }
  }

  Future<void> fetchFavorites(String userId) async {
    if (userId.isEmpty) {
      _favorites = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _favorites = await _favoriteService.fetchFavorites(userId);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavorite(RoomModel room, String userId) async {
    if (userId.isEmpty) return; // Must be logged in

    final isFav = isFavorite(room.id);

    // Optimistic UI update
    if (isFav) {
      _favorites.removeWhere((r) => r.id == room.id);
    } else {
      _favorites.add(room);
    }
    notifyListeners();

    // Sync with backend
    bool success;
    if (isFav) {
      success = await _favoriteService.removeFavorite(userId, room.id);
    } else {
      success = await _favoriteService.addFavorite(userId, room.id);
    }

    // Revert if failed
    if (!success) {
      if (isFav) {
        _favorites.add(room);
      } else {
        _favorites.removeWhere((r) => r.id == room.id);
      }
      notifyListeners();
    }
  }

  void clearFavorites() {
    _favorites = [];
    notifyListeners();
  }
}
