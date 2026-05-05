import 'package:flutter/material.dart';
import '../models/room_model.dart';
import '../../../core/utils/logger.dart';
import '../services/property_service.dart';

class HomeProvider with ChangeNotifier {
  final PropertyService _propertyService = PropertyService();

  List<RoomModel> _rooms = [];
  bool _isLoading = false;

  String _searchQuery = '';
  double _maxPrice = 100000;
  bool _isMapView = false;
  String _selectedCategory = 'All';
  String _selectedLayout = 'All';
  String _selectedProvince = 'All';

  static const List<String> categories = [
    'All',
    'Dormitory',
    'Apartment',
    'House',
    'Studio',
    'Condo',
  ];

  static const List<String> layouts = [
    'All',
    'Studio',
    '1 ห้องนอน',
    '2 ห้องนอน',
    '3 ห้องนอน',
    'อื่นๆ',
  ];

  static const List<String> provinces = [
    'All',
    'กรุงเทพมหานคร',
    'กระบี่',
    'กาญจนบุรี',
    'กาฬสินธุ์',
    'กำแพงเพชร',
    'ขอนแก่น',
    'จันทบุรี',
    'ฉะเชิงเทรา',
    'ชลบุรี',
    'ชัยนาท',
    'ชัยภูมิ',
    'ชุมพร',
    'เชียงราย',
    'เชียงใหม่',
    'ตรัง',
    'ตราด',
    'ตาก',
    'นครนายก',
    'นครปฐม',
    'นครพนม',
    'นครราชสีมา',
    'นครศรีธรรมราช',
    'นครสวรรค์',
    'นนทบุรี',
    'นราธิวาส',
    'น่าน',
    'บึงกาฬ',
    'บุรีรัมย์',
    'ปทุมธานี',
    'ประจวบคีรีขันธ์',
    'ปราจีนบุรี',
    'ปัตตานี',
    'พระนครศรีอยุธยา',
    'พะเยา',
    'พังงา',
    'พัทลุง',
    'พิจิตร',
    'พิษณุโลก',
    'เพชรบุรี',
    'เพชรบูรณ์',
    'แพร่',
    'ภูเก็ต',
    'มหาสารคาม',
    'มุกดาหาร',
    'แม่ฮ่องสอน',
    'ยโสธร',
    'ยะลา',
    'ร้อยเอ็ด',
    'ระนอง',
    'ระยอง',
    'ราชบุรี',
    'ลพบุรี',
    'ลำปาง',
    'ลำพูน',
    'เลย',
    'ศรีสะเกษ',
    'สกลนคร',
    'สงขลา',
    'สตูล',
    'สมุทรปราการ',
    'สมุทรสงคราม',
    'สมุทรสาคร',
    'สระแก้ว',
    'สระบุรี',
    'สิงห์บุรี',
    'สุโขทัย',
    'สุพรรณบุรี',
    'สุราษฎร์ธานี',
    'สุรินทร์',
    'หนองคาย',
    'หนองบัวลำภู',
    'อ่างทอง',
    'อำนาจเจริญ',
    'อุดรธานี',
    'อุตรดิตถ์',
    'อุทัยธานี',
    'อุบลราชธานี'
  ];

  List<RoomModel> get rooms {
    return _rooms.where((room) {
      final matchesSearch =
          room.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          room.locationName.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesPrice = room.price <= _maxPrice;
      final matchesCategory =
          _selectedCategory == 'All' || room.type == _selectedCategory;
      final matchesLayout =
          _selectedLayout == 'All' || room.roomLayout == _selectedLayout;
      final matchesProvince =
          _selectedProvince == 'All' || room.province == _selectedProvince;
      return matchesSearch && matchesPrice && matchesCategory && matchesLayout && matchesProvince;
    }).toList();
  }

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  double get maxPrice => _maxPrice;
  bool get isMapView => _isMapView;
  String get selectedCategory => _selectedCategory;
  String get selectedLayout => _selectedLayout;
  String get selectedProvince => _selectedProvince;

  HomeProvider() {
    fetchRooms();
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

  void setLayout(String layout) {
    _selectedLayout = layout;
    notifyListeners();
  }

  void setFilterAdvanced({
    String? query,
    double? price,
    String? category,
    String? layout,
    String? province,
  }) {
    if (query != null) _searchQuery = query;
    if (price != null) _maxPrice = price;
    if (category != null) _selectedCategory = category;
    if (layout != null) _selectedLayout = layout;
    if (province != null) _selectedProvince = province;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _maxPrice = 100000;
    _selectedCategory = 'All';
    _selectedLayout = 'All';
    _selectedProvince = 'All';
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
      final fetchedRooms = await _propertyService.fetchProperties();
      _rooms = fetchedRooms;
    } catch (e) {
      Logger.error('Failed to fetch rooms', e);
      _rooms = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProperty(Map<String, dynamic> propertyData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newRoom = await _propertyService.createProperty(propertyData);
      if (newRoom != null) {
        _rooms.insert(0, newRoom); // Add to the top of the list
        return true;
      }
      return false;
    } catch (e) {
      Logger.error('Failed to create property', e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProperty(String id, Map<String, dynamic> propertyData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedRoom = await _propertyService.updateProperty(id, propertyData);
      if (updatedRoom != null) {
        final index = _rooms.indexWhere((r) => r.id == id);
        if (index != -1) {
          _rooms[index] = updatedRoom;
        }
        return true;
      }
      return false;
    } catch (e) {
      Logger.error('Failed to update property', e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProperty(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _propertyService.deleteProperty(id);
      if (success) {
        _rooms.removeWhere((r) => r.id == id);
        return true;
      }
      return false;
    } catch (e) {
      Logger.error('Failed to delete property', e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
