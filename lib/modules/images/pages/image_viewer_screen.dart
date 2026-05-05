import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:photo_view/photo_view.dart';

class ImageViewerScreen extends StatelessWidget {
  final String imageUrl;
  final Uint8List? imageBytes;
  final String heroTag;
  final double aspectRatio;
  final bool isEditable;

  const ImageViewerScreen({
    super.key,
    required this.imageUrl,
    this.imageBytes,
    required this.heroTag,
    this.aspectRatio = 1.0,
    this.isEditable = false,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (imageBytes != null) {
      imageProvider = MemoryImage(imageBytes!);
    } else if (imageUrl.isNotEmpty) {
      imageProvider = NetworkImage(imageUrl);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image View with Zoom
          Center(
            child: imageProvider != null
                ? Hero(
                    tag: heroTag,
                    child: PhotoView(
                      imageProvider: imageProvider,
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2,
                      backgroundDecoration: const BoxDecoration(
                        color: Colors.black,
                      ),
                    ),
                  )
                : const Center(
                    child: Text(
                      'ไม่มีรูปภาพ',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ),

          // Top Bar (Back Button)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black.withValues(alpha: 0.5),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
