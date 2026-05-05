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
import '../models/room_model.dart';
import '../../images/utils/image_compressor.dart';
import '../../images/services/i_storage_service.dart';

class EditPropertyPage extends StatefulWidget {
  final RoomModel room;
  const EditPropertyPage({super.key, required this.room});

  @override
  State<EditPropertyPage> createState() => _EditPropertyPageState();
}

class _EditPropertyPageState extends State<EditPropertyPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _dailyRateController;
  late final TextEditingController _roomSizeController;
  late final TextEditingController _locationController;
  late final TextEditingController _depositController;
  late final TextEditingController _advanceController;
  late final TextEditingController _waterRateController;
  late final TextEditingController _electricRateController;
  late final TextEditingController _phoneController;
  late final TextEditingController _lineIdController;

  late String _selectedType;
  late String _selectedRoomLayout;
  late String _selectedProvince;
  late bool _isAvailable;
  late double _latitude;
  late double _longitude;

  // รูปภาพเก่าจาก URL + รูปใหม่จากเครื่อง
  late List<String> _existingImageUrls;
  final List<XFile> _newImages = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> _types = ['Dormitory', 'Apartment', 'House', 'Studio', 'Condo'];
  final List<String> _roomLayouts = ['Studio', '1 ห้องนอน', '2 ห้องนอน', '3 ห้องนอน', 'อื่นๆ'];

  final Map<String, bool> _amenities = {
    'เครื่องปรับอากาศ': false, 'พัดลม': false,
    'เฟอร์นิเจอร์ครบ (ตู้, เตียง)': false, 'เครื่องทำน้ำอุ่น': false,
    'ตู้เย็น': false, 'มี TV': false, 'โต๊ะ - เก้าอี้ทำงาน': false,
    'เตาปรุงอาหาร': false, 'ไมโครเวฟ': false,
    'อินเตอร์เน็ตไร้สาย (Wi-Fi) ฟรี': false, 'เคเบิ้ลทีวี / ดาวเทียม': false,
    'ที่จอดรถยนต์': false, 'ที่จอดรถมอเตอร์ไซต์': false,
    'คีย์การ์ด': false, 'สแกนนิ้วมือ': false,
    'กล้องวงจรปิด (CCTV)': false, 'รปภ. 24 ชม.': false,
    'ลิฟต์': false, 'สระว่ายน้ำ': false, 'โรงยิม / ฟิตเนส': false,
    'ร้านซัก-รีด / เครื่องซักผ้า': false, 'ร้านขายอาหาร': false,
    'ร้านค้า / สะดวกซื้อ': false, 'สถานี Charge รถไฟฟ้า': false,
    'อนุญาตเลี้ยงสัตว์': false,
  };

  @override
  void initState() {
    super.initState();
    final r = widget.room;
    _titleController = TextEditingController(text: r.title);
    _descriptionController = TextEditingController(text: r.description);
    _priceController = TextEditingController(text: r.price.toStringAsFixed(0));
    _dailyRateController = TextEditingController(text: r.dailyRate > 0 ? r.dailyRate.toStringAsFixed(0) : '');
    _roomSizeController = TextEditingController(text: r.roomSize);
    _locationController = TextEditingController(text: r.locationName);
    _depositController = TextEditingController(text: r.depositMonths.toString());
    _advanceController = TextEditingController(text: r.advanceMonths.toString());
    _waterRateController = TextEditingController(text: r.waterRate);
    _electricRateController = TextEditingController(text: r.electricityRate);
    _phoneController = TextEditingController(text: r.ownerPhone);
    _lineIdController = TextEditingController(text: r.ownerLineId);
    _selectedType = r.type;
    _selectedRoomLayout = r.roomLayout;
    _selectedProvince = r.province.isNotEmpty ? r.province : 'กรุงเทพมหานคร';
    _isAvailable = r.isAvailable;
    _latitude = r.latitude;
    _longitude = r.longitude;
    _existingImageUrls = List<String>.from(r.imageUrls);

    // ติ๊ก amenities ที่มีอยู่แล้ว
    for (var a in r.amenities) {
      if (_amenities.containsKey(a)) _amenities[a] = true;
    }
  }

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

      try {
        // อัพโหลดรูปใหม่ (ถ้ามี)
        final newUrls = await _uploadNewImages();

        if (!mounted) return;

        final allImageUrls = [..._existingImageUrls, ...newUrls];

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
          'imageUrls': allImageUrls,
        };

        final provider = context.read<HomeProvider>();
        final success = await provider.updateProperty(widget.room.id, propertyData);

        if (!mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('บันทึกการแก้ไขเรียบร้อย!', style: TextStyle(fontSize: 16)),
              backgroundColor: Colors.green,
            ),
          );
          context.pop(true); // ส่ง true กลับเพื่อแจ้งว่ามีการอัปเดต
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('เกิดข้อผิดพลาด กรุณาลองใหม่', style: TextStyle(fontSize: 16)),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เกิดข้อผิดพลาด: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage();
    if (images.isNotEmpty) setState(() => _newImages.addAll(images));
  }

  void _removeExistingImage(int index) {
    setState(() => _existingImageUrls.removeAt(index));
  }

  void _removeNewImage(int index) {
    setState(() => _newImages.removeAt(index));
  }

  Future<List<String>> _uploadNewImages() async {
    if (_newImages.isEmpty) return [];
    final storageService = context.read<IStorageService>();

    final List<File> filesToUpload = [];
    for (var xFile in _newImages) {
      final compressed = await ImageCompressor.compressImage(File(xFile.path));
      if (compressed != null) filesToUpload.add(compressed);
    }
    if (filesToUpload.isEmpty) return [];

    final fileNames = filesToUpload.map((f) => path.basename(f.path)).toList();
    final storageItems = await storageService.getPresignedUrls(
      filenames: fileNames, state: 'properties',
    );

    final List<String> finalUrls = [];
    for (int i = 0; i < storageItems.length; i++) {
      await storageService.uploadFile(uploadUrl: storageItems[i].uploadUrl, file: filesToUpload[i]);
      finalUrls.add(storageItems[i].publicUrl);
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
                  Text('จิ้มเลือกตำแหน่งที่ตั้ง', style: AppTypography.fontTitleSmallProminent()),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('ตกลง', style: AppTypography.fontTitleSmallProminentPrimary()),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(_latitude, _longitude),
                  initialZoom: 13.0,
                  onTap: (_, point) => setState(() {
                    _latitude = point.latitude;
                    _longitude = point.longitude;
                  }),
                ),
                children: [
                  TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                  MarkerLayer(markers: [
                    Marker(
                      point: LatLng(_latitude, _longitude),
                      width: 50, height: 50,
                      child: const Icon(Icons.location_on, color: AppColors.primary, size: 40),
                    ),
                  ]),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('คลิกบนแผนที่เพื่อย้ายหมุด', style: TextStyle(color: AppColors.textSecondary)),
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
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 10),
        Text(title, style: AppTypography.fontTitleSmallProminentPrimary()),
      ]),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
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
        decoration: InputDecoration(labelText: label, hintText: hint, suffixText: suffixText),
        validator: validator ?? (v) => (v == null || v.isEmpty) ? 'กรุณากรอกข้อมูลส่วนนี้' : null,
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

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<HomeProvider>().isLoading;
    final totalImages = _existingImageUrls.length + _newImages.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขประกาศ', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    // ── รูปภาพ ──
                    _buildSectionTitle('รูปภาพที่พัก', icon: Icons.camera_alt_outlined),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: totalImages + 1,
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
                                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo_outlined, color: AppColors.primary, size: 32),
                                    SizedBox(height: 8),
                                    Text('เพิ่มรูปภาพ', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            );
                          }
                          final imgIndex = index - 1;
                          final isExisting = imgIndex < _existingImageUrls.length;
                          return Stack(children: [
                            Container(
                              width: 120,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: DecorationImage(
                                  image: isExisting
                                      ? NetworkImage(_existingImageUrls[imgIndex]) as ImageProvider
                                      : FileImage(File(_newImages[imgIndex - _existingImageUrls.length].path)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4, right: 16,
                              child: GestureDetector(
                                onTap: () => isExisting
                                    ? _removeExistingImage(imgIndex)
                                    : _removeNewImage(imgIndex - _existingImageUrls.length),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ]);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── ข้อมูลทั่วไป ──
                    _buildSectionTitle('ข้อมูลทั่วไป', icon: Icons.home_outlined),
                    _buildTextField(controller: _titleController, label: 'ชื่อหอพัก', hint: 'เช่น ธนภัทร เพลส'),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            label: 'ประเภทที่พัก',
                            value: _selectedType,
                            items: _types,
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedType = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdown(
                            label: 'รูปแบบห้อง',
                            value: _selectedRoomLayout,
                            items: _roomLayouts,
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedRoomLayout = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    _buildTextField(controller: _roomSizeController, label: 'ขนาดห้อง (ตร.ม.)', hint: 'เช่น 25 ตร.ม.', suffixText: 'ตร.ม.'),
                    _buildTextField(controller: _descriptionController, label: 'รายละเอียด', hint: 'รายละเอียดห้อง...', maxLines: 4),
                    _buildTextField(controller: _locationController, label: 'สถานที่ตั้ง', hint: 'เช่น ถ.จิระ ต.ในเมือง อ.เมือง'),
                    _buildDropdown(
                      label: 'จังหวัด',
                      value: _selectedProvince,
                      items: HomeProvider.provinces.where((p) => p != 'All').toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedProvince = val);
                      },
                    ),

                    // แผนที่
                    const SizedBox(height: 10),
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(children: [
                          Container(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Text('Lat: ${_latitude.toStringAsFixed(4)}, Long: ${_longitude.toStringAsFixed(4)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () => _showLocationPicker(context),
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                                  child: const Text('เลือกตำแหน่ง'),
                                ),
                              ]),
                            ),
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── ค่าใช้จ่าย ──
                    _buildSectionTitle('ค่าใช้จ่าย', icon: Icons.payments_outlined),
                    Row(children: [
                      Expanded(child: _buildTextField(controller: _priceController, label: 'รายเดือน (บาท)', hint: '3500', keyboardType: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField(controller: _dailyRateController, label: 'รายวัน (บาท)', hint: '550', keyboardType: TextInputType.number, validator: (v) => null)),
                    ]),
                    Row(children: [
                      Expanded(child: _buildTextField(controller: _depositController, label: 'มัดจำ (เดือน)', hint: '2', keyboardType: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField(controller: _advanceController, label: 'จ่ายล่วงหน้า (เดือน)', hint: '1', keyboardType: TextInputType.number)),
                    ]),
                    Row(children: [
                      Expanded(child: _buildTextField(controller: _waterRateController, label: 'ค่าน้ำ', hint: 'เรทการประปา')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField(controller: _electricRateController, label: 'ค่าไฟ', hint: '8 บาท/หน่วย')),
                    ]),

                    // ── ข้อมูลติดต่อ ──
                    _buildSectionTitle('ข้อมูลติดต่อ', icon: Icons.phone_outlined),
                    _buildTextField(controller: _phoneController, label: 'เบอร์โทรศัพท์', hint: '081-146-7754', keyboardType: TextInputType.phone),
                    _buildTextField(controller: _lineIdController, label: 'LINE ID', hint: '@myline', validator: (v) => null),

                    // ── สถานะห้อง ──
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade50,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('สถานะห้อง', style: TextStyle(fontSize: 16)),
                            Row(children: [
                              Text(_isAvailable ? 'ว่าง' : 'ไม่ว่าง',
                                  style: TextStyle(fontSize: 16, color: _isAvailable ? Colors.green : Colors.red, fontWeight: FontWeight.w600)),
                              Switch(value: _isAvailable, activeThumbColor: AppColors.primary, onChanged: (v) => setState(() => _isAvailable = v)),
                            ]),
                          ],
                        ),
                      ),
                    ),

                    // ── สิ่งอำนวยความสะดวก ──
                    _buildSectionTitle('สิ่งอำนวยความสะดวก', icon: Icons.check_circle_outline),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _amenities.keys.map((amenity) {
                        return FilterChip(
                          label: Text(amenity, style: const TextStyle(fontSize: 13)),
                          selected: _amenities[amenity]!,
                          selectedColor: AppColors.primary.withValues(alpha: 0.2),
                          checkmarkColor: AppColors.primary,
                          onSelected: (val) => setState(() => _amenities[amenity] = val),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('บันทึกการแก้ไข',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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
