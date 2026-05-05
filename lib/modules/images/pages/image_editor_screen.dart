import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/colors.dart';
import '../../../core/config/typography.dart';
import 'image_editor_cropper.dart';

enum ImageEditorMode {
  crop, // For avatar -> Returns cropped bytes
  position, // For cover -> Returns original bytes + position
}

class ImageEditorResult {
  final Uint8List bytes;
  final double? positionX;
  final double? positionY;
  final double? scale;

  const ImageEditorResult({
    required this.bytes,
    this.positionX,
    this.positionY,
    this.scale,
  });
}

class ImageEditorScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final double aspectRatio;
  final String title;
  final ImageEditorMode mode;
  final VoidCallback? onBack;
  final Future<void> Function(
    Uint8List bytes, {
    double? x,
    double? y,
    double? scale,
  })?
  onSave;
  final String? successMessage;

  const ImageEditorScreen({
    super.key,
    required this.imageBytes,
    required this.aspectRatio,
    required this.mode,
    this.title = 'แก้ไขรูปภาพ',
    this.onBack,
    this.onSave,
    this.successMessage,
  });

  static Future<ImageEditorResult?> show({
    required BuildContext context,
    required Uint8List imageBytes,
    required double aspectRatio,
    ImageEditorMode mode = ImageEditorMode.crop,
    String? title,
    VoidCallback? onBack,
    Future<void> Function(Uint8List, {double? x, double? y, double? scale})?
    onSave,
    String? successMessage,
    bool replace = false,
  }) {
    if (replace) {
      context.pushReplacement(
        '/image/editor',
        extra: {
          'imageBytes': imageBytes,
          'aspectRatio': aspectRatio,
          'mode': mode,
          'title': title ?? 'แก้ไขรูปภาพ',
          'onBack': onBack,
          'onSave': onSave,
          'successMessage': successMessage,
        },
      );
      return Future.value(null);
    } else {
      return context.push<ImageEditorResult?>(
        '/image/editor',
        extra: {
          'imageBytes': imageBytes,
          'aspectRatio': aspectRatio,
          'mode': mode,
          'title': title ?? 'แก้ไขรูปภาพ',
          'onBack': onBack,
          'onSave': onSave,
          'successMessage': successMessage,
        },
      );
    }
  }

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  // Controller
  final CustomCropController _cropController = CustomCropController();

  // State
  bool _isSaving = false;

  void handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      context.pop();
    }
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    // แสดง Loading simple แบบมาตรฐาน
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      Uint8List? resultBytes;
      double? posX, posY, scale;

      if (widget.mode == ImageEditorMode.crop) {
        resultBytes = await _cropController.crop();
      } else {
        final position = _cropController.getPosition();
        if (position != null) {
          resultBytes = widget.imageBytes;
          posX = position.x;
          posY = position.y;
          scale = position.scale;
        }
      }

      if (resultBytes != null) {
        if (widget.onSave != null) {
          // Perform the save operation
          await widget.onSave!(resultBytes, x: posX, y: posY, scale: scale);

          // After await, we MUST check if we are still mounted
          if (!mounted) {
            // If unmounted, the callback likely already popped us.
            // But we still need to make sure the Loading dialog (on root) is gone.
            // However, we can't use our context if unmounted.
            return;
          }

          // ปิด Loading
          if (mounted) Navigator.of(context, rootNavigator: true).pop();

          if (widget.successMessage != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(widget.successMessage!)),
            );
          }
          handleBack();
        } else {
          // No custom onSave, so we close the dialog and pop with result
          if (mounted) {
            Navigator.of(context, rootNavigator: true).pop(); // ปิด Loading
            context.pop(
              ImageEditorResult(
                bytes: resultBytes,
                positionX: posX,
                positionY: posY,
                scale: scale,
              ),
            );
          }
        }
      } else {
        if (mounted) Navigator.of(context, rootNavigator: true).pop();
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        handleBack();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => handleBack(),
          ),
          title: Text(
            widget.title,
            style: AppTypography.fontTitleMediumProminent(
              color: Colors.white,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: InkWell(
                onTap: _isSaving ? null : _handleSave,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 8.0,
                  ),
                  decoration: ShapeDecoration(
                    color: _isSaving
                        ? AppColors.primary.withValues(alpha: 0.5)
                        : AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999.0),
                    ),
                  ),
                  child: Text(
                    'บันทึก',
                    style: AppTypography.fontBodyMediumProminent(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Center(
          child: CustomImageCropper(
            controller: _cropController,
            imageBytes: widget.imageBytes,
            aspectRatio: widget.mode == ImageEditorMode.crop
                ? 1.0
                : widget.aspectRatio,
            isCircle:
                widget.mode == ImageEditorMode.crop &&
                widget.aspectRatio == 1.0,
            overlayColor: Colors.black.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
