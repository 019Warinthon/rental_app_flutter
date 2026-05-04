import 'package:flutter/material.dart';
import '../models/room_model.dart';
import '../../../core/api/api_client.dart';
import '../../../core/utils/logger.dart';
import '../../main/providers/favorites_provider.dart';

class HomeProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<RoomModel> _rooms = [];
  bool _isLoading = false;

  String _searchQuery = '';
  double _maxPrice = 100000;
  bool _isMapView = false;
  String _selectedCategory = 'All';

  static const List<String> categories = [
    'All',
    'Apartment',
    'Studio',
    'Dormitory',
    'Penthouse',
  ];

  List<RoomModel> get rooms {
    return _rooms.where((room) {
      final matchesSearch =
          room.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              room.locationName
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
      final matchesPrice = room.price <= _maxPrice;
      final matchesCategory =
          _selectedCategory == 'All' || room.type == _selectedCategory;
      return matchesSearch && matchesPrice && matchesCategory;
    }).toList();
  }

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  double get maxPrice => _maxPrice;
  bool get isMapView => _isMapView;
  String get selectedCategory => _selectedCategory;

  FavoritesProvider? _favoritesProvider;

  HomeProvider() {
    fetchRooms();
  }

  void attachFavorites(FavoritesProvider fav) {
    _favoritesProvider = fav;
  }

  void setFilter(String query, double price) {
    _searchQuery = query;
    _maxPrice = price;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _maxPrice = 100000;
    _selectedCategory = 'All';
    notifyListeners();
  }

  void toggleMapView() {
    _isMapView = !_isMapView;
    notifyListeners();
  }

  Future<void> fetchRooms() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.get('/api/properties');
      final List<dynamic> data = response['data'];
      _rooms = data.map((json) => RoomModel.fromJson(json)).toList();
      // Restore favorites from disk now that rooms are available
      if (_favoritesProvider != null) {
        await _favoritesProvider!.loadFromDisk(_rooms);
      }
    } catch (e) {
      Logger.error('Failed to fetch rooms', e);
      _rooms = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
