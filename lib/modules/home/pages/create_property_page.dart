import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../../../core/config/colors.dart';
import '../../../core/config/typography.dart';
import '../providers/home_provider.dart';
import '../../images/utils/image_compressor.dart';
import '../../images/services/i_storage_service.dart';

class CreatePropertyPage extends StatefulWidget {
  const CreatePropertyPage({super.key});

  @override
  State<CreatePropertyPage> createState() => _CreatePropertyPageState();
}

class _CreatePropertyPageState extends State<CreatePropertyPage> {
  final _formKey = GlobalKey<FormState>();

  // ── Controllers ───────────────────────────────────────────────
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _dailyRateController = TextEditingController();
  final _roomSizeController = TextEditingController();
  final _locationController = TextEditingController();
  final _depositController = TextEditingController();
  final _advanceController = TextEditingController();
  final _waterRateController = TextEditingController();
  final _electricRateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _lineIdController = TextEditingController();

  String _selectedType = 'Dormitory';
  String _selectedRoomLayout = 'Studio';
  String _selectedProvince = 'กรุงเทพมหานคร';
  bool _isAvailable = true;
  
  // พิกัดเริ่มต้น (กรุงเทพ)
  double _latitude = 13.7563;
  double _longitude = 100.5018;

  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> _types = [
    'Dormitory',
    'Apartment',
    'House',
    'Studio',
    'Condo',
  ];
  final List<String> _roomLayouts = [
    'Studio',
    '1 ห้องนอน',
    '2 ห้องนอน',
    '3 ห้องนอน',
    'อื่นๆ',
  ];

  // ── Amenities (จาก RentHub) ───────────────────────────────────
  final Map<String, bool> _amenities = {
    // ห้อง & เฟอร์นิเจอร์
    'เครื่องปรับอากาศ': false,
    'พัดลม': false,
    'เฟอร์นิเจอร์ครบ (ตู้, เตียง)': false,
    'เครื่องทำน้ำอุ่น': false,
    'ตู้เย็น': false,
    'มี TV': false,
    'โต๊ะ - เก้าอี้ทำงาน': false,
    'เตาปรุงอาหาร': false,
    'ไมโครเวฟ': false,
    // อินเทอร์เน็ต & ความบันเทิง
    'อินเตอร์เน็ตไร้สาย (Wi-Fi) ฟรี': false,
    'เคเบิ้ลทีวี / ดาวเทียม': false,
    // จอดรถ
    'ที่จอดรถยนต์': false,
    'ที่จอดรถมอเตอร์ไซต์': false,
    // ความปลอดภัย
    'คีย์การ์ด': false,
    'สแกนนิ้วมือ': false,
    'กล้องวงจรปิด (CCTV)': false,
    'รปภ. 24 ชม.': false,
    // สิ่งอำนวยความสะดวกอาคาร
    'ลิฟต์': false,
    'สระว่ายน้ำ': false,
    'โรงยิม / ฟิตเนส': false,
    'ร้านซัก-รีด / เครื่องซักผ้า': false,
    'ร้านขายอาหาร': false,
    'ร้านค้า / สะดวกซื้อ': false,
    'สถานี Charge รถไฟฟ้า': false,
    // กฎห้องพัก
    'อนุญาตเลี้ยงสัตว์': false,
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _dailyRateController.dispose();
    _roomSizeController.dispose();
    _locationController.dispose();
    _depositController.dispose();
    _advanceController.dispose();
    _waterRateController.dispose();
    _electricRateController.dispose();
    _phoneController.dispose();
    _lineIdController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final selectedAmenities = _amenities.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      final propertyData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'dailyRate': double.tryParse(_dailyRateController.text) ?? 0.0,
        'roomSize': _roomSizeController.text,
        'roomLayout': _selectedRoomLayout,
        'locationName': _locationController.text,
        'province': _selectedProvince,
        'type': _selectedType,
        'isAvailable': _isAvailable,
        'depositMonths': int.tryParse(_depositController.text) ?? 1,
        'advanceMonths': int.tryParse(_advanceController.text) ?? 1,
        'waterRate': _waterRateController.text,
        'electricityRate': _electricRateController.text,
        'ownerPhone': _phoneController.text,
        'ownerLineId': _lineIdController.text,
        'amenities': selectedAmenities,
        'latitude': _latitude,
        'longitude': _longitude,
        'images': [], 
      };

      try {
        // 1. อัพโหลดรูปภาพก่อน
        final imageUrls = await _uploadImages();

        if (!mounted) return;
        propertyData['images'] = imageUrls;

        // 2. ส่งข้อมูลทั้งหมดไปบันทึก
        final provider = context.read<HomeProvider>();
        final success = await provider.createProperty(propertyData);

        if (!mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'สร้างประกาศเรียบร้อยแล้ว!',
                style: TextStyle(fontSize: 16),
              ),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'เกิดข้อผิดพลาด กรุณาลองใหม่',
                style: TextStyle(fontSize: 16),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('เกิดข้อผิดพลาดในการอัพโหลด: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // ── Helpers ───────────────────────────────────────────────────

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<List<String>> _uploadImages() async {
    if (_selectedImages.isEmpty) return [];

    final storageService = context.read<IStorageService>();
    
    // 1. แปลงไฟล์และบีบอัดก่อน (เพื่อความประหยัดพื้นที่ Cloud)
    final List<File> filesToUpload = [];
    for (var xFile in _selectedImages) {
      final compressed = await ImageCompressor.compressImage(File(xFile.path));
      if (compressed != null) {
        filesToUpload.add(compressed);
      }
    }

    if (filesToUpload.isEmpty) return [];

    // 2. ขอ Presigned URLs จาก Backend
    final fileNames = filesToUpload.map((f) => path.basename(f.path)).toList();
    final storageItems = await storageService.getPresignedUrls(
      filenames: fileNames,
      state: 'properties',
    );

    // 3. อัพโหลดไฟล์จริงๆ เข้า Google Cloud
    final List<String> finalUrls = [];
    for (int i = 0; i < storageItems.length; i++) {
      final item = storageItems[i];
      final file = filesToUpload[i];

      await storageService.uploadFile(
        uploadUrl: item.uploadUrl,
        file: file,
      );
      finalUrls.add(item.publicUrl);
    }

    return finalUrls;
  }

  void _showLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'จิ้มเลือกตำแหน่งที่ตั้ง',
                    style: AppTypography.fontTitleSmallProminent(),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      'ตกลง',
                      style: AppTypography.fontTitleSmallProminentPrimary(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(_latitude, _longitude),
                  initialZoom: 13.0,
                  onTap: (tapPosition, point) {
                    setState(() {
                      _latitude = point.latitude;
                      _longitude = point.longitude;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(_latitude, _longitude),
                        width: 50,
                        height: 50,
                        child: const Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'คลิกบนแผนที่เพื่อย้ายหมุดไปยังตำแหน่งหอพักของคุณ',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(top: 28.0, bottom: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: AppTypography.fontTitleSmallProminentPrimary(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? prefixText,
    String? suffixText,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 17),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixText: prefixText,
          suffixText: suffixText,
        ),
        validator:
            validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return 'กรุณากรอกข้อมูลส่วนนี้';
              }
              return null;
            },
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: DropdownButtonFormField<String>(
        value: value,
        style: const TextStyle(fontSize: 17, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
        ),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildAmenitiesSection() {
    // จัดกลุ่ม amenities
    final groups = <String, List<String>>{
      '🛏️ ห้องพัก & เฟอร์นิเจอร์': [
        'เครื่องปรับอากาศ',
        'พัดลม',
        'เฟอร์นิเจอร์ครบ (ตู้, เตียง)',
        'เครื่องทำน้ำอุ่น',
        'ตู้เย็น',
        'มี TV',
        'โต๊ะ - เก้าอี้ทำงาน',
        'เตาปรุงอาหาร',
        'ไมโครเวฟ',
      ],
      '🌐 อินเทอร์เน็ต & บันเทิง': [
        'อินเตอร์เน็ตไร้สาย (Wi-Fi) ฟรี',
        'เคเบิ้ลทีวี / ดาวเทียม',
      ],
      '🚗 จอดรถ': ['ที่จอดรถยนต์', 'ที่จอดรถมอเตอร์ไซต์'],
      '🔒 ความปลอดภัย': [
        'คีย์การ์ด',
        'สแกนนิ้วมือ',
        'กล้องวงจรปิด (CCTV)',
        'รปภ. 24 ชม.',
      ],
      '🏢 สิ่งอำนวยความสะดวกอาคาร': [
        'ลิฟต์',
        'สระว่ายน้ำ',
        'โรงยิม / ฟิตเนส',
        'ร้านซัก-รีด / เครื่องซักผ้า',
        'ร้านขายอาหาร',
        'ร้านค้า / สะดวกซื้อ',
        'สถานี Charge รถไฟฟ้า',
      ],
      '🐾 กฎห้องพัก': ['อนุญาตเลี้ยงสัตว์'],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'สิ่งอำนวยความสะดวก',
          icon: Icons.check_circle_outline,
        ),
        ...groups.entries.map((group) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                  child: Text(
                    group.key,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Wrap(
                  children: group.value.map((amenity) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width / 2 - 36,
                      child: CheckboxListTile(
                        title: Text(
                          amenity,
                          style: const TextStyle(fontSize: 14),
                        ),
                        value: _amenities[amenity] ?? false,
                        activeColor: AppColors.primary,
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        dense: true,
                        onChanged: (val) {
                          setState(() => _amenities[amenity] = val ?? false);
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 4),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<HomeProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ลงประกาศปล่อยเช่า',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── รูปภาพที่พัก ──────────────────────────────
                    _buildSectionTitle(
                      'รูปภาพที่พัก',
                      icon: Icons.camera_alt_outlined,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return GestureDetector(
                              onTap: _pickImages,
                              child: Container(
                                width: 120,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    style: BorderStyle.solid,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add_a_photo_outlined,
                                      color: AppColors.primary,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'เพิ่มรูปภาพ',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          final imageIndex = index - 1;
                          return Stack(
                            children: [
                              Container(
                                width: 120,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  image: DecorationImage(
                                    image: FileImage(
                                      File(_selectedImages[imageIndex].path),
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 16,
                                child: GestureDetector(
                                  onTap: () => _removeImage(imageIndex),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── ข้อมูลทั่วไป ──────────────────────────────
                    _buildSectionTitle(
                      'ข้อมูลทั่วไป',
                      icon: Icons.home_outlined,
                    ),
                    _buildTextField(
                      controller: _titleController,
                      label: 'ชื่อหอพัก / ชื่อสถานที่',
                      hint: 'เช่น ธนภัทร เพลส ถ.จิระ',
                    ),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'รายละเอียดห้องพัก',
                      hint: 'เช่น เฟอร์นิเจอร์ครบ หิ้วกระเป๋าเข้าอยู่ได้เลย...',
                      maxLines: 4,
                    ),
                      _buildTextField(
                        controller: _locationController,
                        label: 'สถานที่ตั้งโดยละเอียด',
                        hint: 'เช่น ถ.จิระ ต.ในเมือง อ.เมือง',
                      ),
                      _buildDropdown(
                        label: 'จังหวัด',
                        value: _selectedProvince,
                        items: HomeProvider.provinces.where((p) => p != 'All').toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedProvince = val);
                        },
                      ),
                      
                      // ── แผนที่เลือกพิกัด ──────────────────────────
                      const Text(
                        'ระบุตำแหน่งบนแผนที่',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              Image.asset(
                                'assets/images/map_placeholder.png', // Fallback if no real map
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                              Container(
                                color: Colors.black.withValues(alpha: 0.3),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.map_outlined, color: Colors.white, size: 40),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Lat: ${_latitude.toStringAsFixed(4)}, Long: ${_longitude.toStringAsFixed(4)}',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        onPressed: () => _showLocationPicker(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('เลือกตำแหน่ง'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    _buildDropdown(
                      label: 'ประเภทที่พัก',
                      value: _selectedType,
                      items: _types,
                      onChanged: (v) => setState(() => _selectedType = v!),
                    ),

                    // ── ข้อมูลห้อง ─────────────────────────────────
                    _buildSectionTitle(
                      'ข้อมูลห้อง',
                      icon: Icons.door_front_door_outlined,
                    ),
                    _buildDropdown(
                      label: 'รูปแบบห้อง',
                      value: _selectedRoomLayout,
                      items: _roomLayouts,
                      onChanged: (v) =>
                          setState(() => _selectedRoomLayout = v!),
                    ),
                    _buildTextField(
                      controller: _roomSizeController,
                      label: 'ขนาดห้อง (ตร.ม.)',
                      hint: 'เช่น 23.6',
                      keyboardType: TextInputType.number,
                      suffixText: 'ตร.ม.',
                      validator: (v) => null, // Optional
                    ),
                    // สถานะห้อง
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade50,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'สถานะห้อง',
                              style: TextStyle(fontSize: 16),
                            ),
                            Row(
                              children: [
                                Text(
                                  _isAvailable ? 'ว่าง' : 'ไม่ว่าง',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _isAvailable
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Switch(
                                  value: _isAvailable,
                                  activeThumbColor: AppColors.primary,
                                  onChanged: (v) =>
                                      setState(() => _isAvailable = v),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── สิ่งอำนวยความสะดวก ────────────────────────
                    _buildAmenitiesSection(),

                    // ── ค่าใช้จ่าย ─────────────────────────────────
                    _buildSectionTitle(
                      'ค่าใช้จ่าย',
                      icon: Icons.payments_outlined,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _priceController,
                            label: 'รายเดือน (บาท)',
                            hint: 'เช่น 3500',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _dailyRateController,
                            label: 'รายวัน (บาท)',
                            hint: 'เช่น 550',
                            keyboardType: TextInputType.number,
                            validator: (v) => null, // Optional
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _depositController,
                            label: 'มัดจำ (เดือน)',
                            hint: 'เช่น 2',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _advanceController,
                            label: 'จ่ายล่วงหน้า (เดือน)',
                            hint: 'เช่น 1',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _waterRateController,
                            label: 'ค่าน้ำ',
                            hint: 'เช่น เรทการประปา',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _electricRateController,
                            label: 'ค่าไฟ',
                            hint: 'เช่น 8 บาท/หน่วย',
                          ),
                        ),
                      ],
                    ),

                    // ── ข้อมูลติดต่อ ────────────────────────────────
                    _buildSectionTitle(
                      'ข้อมูลติดต่อ',
                      icon: Icons.phone_outlined,
                    ),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'เบอร์โทรศัพท์',
                      hint: 'เช่น 081-146-7754',
                      keyboardType: TextInputType.phone,
                    ),
                    _buildTextField(
                      controller: _lineIdController,
                      label: 'ไอดีไลน์ (LINE ID)',
                      hint: 'เช่น @myline หรือเบอร์โทร',
                      validator: (v) => null,
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'ลงประกาศ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}
