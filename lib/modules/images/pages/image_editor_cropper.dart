import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:typed_data';

class CustomCropController {
  _CustomImageCropperState? _state;

  void _bind(_CustomImageCropperState state) {
    _state = state;
  }

  void _unbind() {
    _state = null;
  }

  Future<Uint8List?> crop() async {
    return _state?.crop();
  }

  /// Returns x, y coordinates as normalized values (0.0 - 1.0)
  /// x: 0.0 = left edge, 0.5 = center, 1.0 = right edge
  /// y: 0.0 = top edge, 0.5 = center, 1.0 = bottom edge
  ({double x, double y, double scale})? getPosition() {
    return _state?.getPosition();
  }
}

class CustomImageCropper extends StatefulWidget {
  final Uint8List imageBytes;
  final CustomCropController controller;
  final double aspectRatio;
  final bool isCircle;
  final Color overlayColor;

  const CustomImageCropper({
    super.key,
    required this.imageBytes,
    required this.controller,
    this.aspectRatio = 1.0,
    this.isCircle = false,
    this.overlayColor = const Color(0xAA000000),
  });

  @override
  State<CustomImageCropper> createState() => _CustomImageCropperState();
}

class _CustomImageCropperState extends State<CustomImageCropper> {
  ui.Image? _image;
  bool _isLoading = true;

  // Transform state
  double _scale = -1.0; // Use -1 to indicate uninitialized
  double _minScale = 1.0;
  Offset _offset = Offset.zero;

  // Viewport
  Rect _viewportRect = Rect.zero;
  Size _imageSize = Size.zero;
  Size? _lastLayoutSize;

  // Interaction
  Offset _startFocalPoint = Offset.zero;
  double _startScale = 1.0;

  @override
  void initState() {
    super.initState();
    widget.controller._bind(this);
    _loadImage();
  }

  @override
  void dispose() {
    widget.controller._unbind();
    _image?.dispose();
    super.dispose();
  }

  Future<void> _loadImage() async {
    final codec = await ui.instantiateImageCodec(widget.imageBytes);
    final frame = await codec.getNextFrame();
    if (mounted) {
      setState(() {
        _image = frame.image;
        _imageSize = Size(_image!.width.toDouble(), _image!.height.toDouble());
        _isLoading = false;
      });
    }
  }

  void _initLayout(Size size) {
    if (_image == null) return;
    _lastLayoutSize = size;

    // Calculate viewport rect centered in container
    double viewportWidth = size.width;
    double viewportHeight = viewportWidth / widget.aspectRatio;

    if (viewportHeight > size.height) {
      viewportHeight = size.height;
      viewportWidth = viewportHeight * widget.aspectRatio;
    }

    final center = size.center(Offset.zero);
    _viewportRect = Rect.fromCenter(
      center: center,
      width: viewportWidth,
      height: viewportHeight,
    );

    if (widget.isCircle) {
      _viewportRect = _viewportRect.deflate(16.0); // Slightly more padding
    }

    // Calculate min scale to fill viewport (Aspect Fill)
    final scaleX = _viewportRect.width / _imageSize.width;
    final scaleY = _viewportRect.height / _imageSize.height;
    _minScale = math.max(scaleX, scaleY);

    // Initial state: centered and min scaled
    if (_scale < 0) {
      _scale = _minScale;

      // Center image in viewport
      final scaledWidth = _imageSize.width * _scale;
      final scaledHeight = _imageSize.height * _scale;

      _offset = Offset(
        center.dx - scaledWidth / 2,
        center.dy - scaledHeight / 2,
      );
    } else {
      // Re-constrain existing transform if layout changed
      if (_scale < _minScale) _scale = _minScale;
      _constrainTransform();
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _startFocalPoint = details.localFocalPoint;
    _startScale = _scale;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_image == null) return;

    setState(() {
      // 1. Update scale ONLY if isCircle is true (Avatar mode)
      if (widget.isCircle) {
        double newScale = _startScale * details.scale;
        // Clamp scale
        if (newScale < _minScale) newScale = _minScale;
        if (newScale > _minScale * 10.0) newScale = _minScale * 10.0;

        // 2. Zoom toward focal point
        final Offset currentFocalPoint = details.localFocalPoint;
        final double scaleRatio = newScale / _scale;

        _offset =
            currentFocalPoint - (currentFocalPoint - _offset) * scaleRatio;
        _scale = newScale;
      }

      // 3. Apply translation (pan) - Always enabled
      _offset += (details.localFocalPoint - _startFocalPoint);
      _startFocalPoint = details.localFocalPoint;

      _constrainTransform();
    });
  }

  void _constrainTransform() {
    if (_image == null || _viewportRect == Rect.zero) return;

    final scaledWidth = _imageSize.width * _scale;
    final scaledHeight = _imageSize.height * _scale;

    double x = _offset.dx;
    double y = _offset.dy;

    // Boundary constraints: ensure viewport is always covered by image
    // Left edge
    if (x > _viewportRect.left) x = _viewportRect.left;
    // Right edge
    if (x + scaledWidth < _viewportRect.right) {
      x = _viewportRect.right - scaledWidth;
    }
    // Top edge
    if (y > _viewportRect.top) y = _viewportRect.top;
    // Bottom edge
    if (y + scaledHeight < _viewportRect.bottom) {
      y = _viewportRect.bottom - scaledHeight;
    }

    _offset = Offset(x, y);
  }

  ({double x, double y, double scale})? getPosition() {
    if (_image == null || _viewportRect == Rect.zero) return null;

    final scaledWidth = _imageSize.width * _scale;
    final scaledHeight = _imageSize.height * _scale;

    final slackX = scaledWidth - _viewportRect.width;
    final slackY = scaledHeight - _viewportRect.height;

    final currentX = _viewportRect.left - _offset.dx;
    final currentY = _viewportRect.top - _offset.dy;

    final normX = slackX > 0.0001 ? (currentX / slackX) : 0.5;
    final normY = slackY > 0.0001 ? (currentY / slackY) : 0.5;

    return (x: normX.clamp(0.0, 1.0), y: normY.clamp(0.0, 1.0), scale: _scale);
  }

  Future<Uint8List?> crop() async {
    if (_image == null || _viewportRect == Rect.zero) return null;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final relativeLeft = _viewportRect.left - _offset.dx;
    final relativeTop = _viewportRect.top - _offset.dy;

    final srcX = relativeLeft / _scale;
    final srcY = relativeTop / _scale;
    final srcW = _viewportRect.width / _scale;
    final srcH = _viewportRect.height / _scale;

    final srcRect = Rect.fromLTWH(srcX, srcY, srcW, srcH);
    final dstSize = Size(srcW, srcH);

    canvas.drawImageRect(
      _image!,
      srcRect,
      Rect.fromLTWH(0, 0, dstSize.width, dstSize.height),
      Paint()..filterQuality = FilterQuality.high,
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(
      dstSize.width.toInt(),
      dstSize.height.toInt(),
    );

    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final currentSize = constraints.biggest;

        // Initialize layout if size changed or not yet initialized
        if (_lastLayoutSize != currentSize) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _initLayout(currentSize);
              });
            }
          });
        }

        return Stack(
          children: [
            GestureDetector(
              onScaleStart: _handleScaleStart,
              onScaleUpdate: _handleScaleUpdate,
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.black,
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    if (_image != null && _viewportRect != Rect.zero)
                      Positioned(
                        left: _offset.dx,
                        top: _offset.dy,
                        child: Transform(
                          transform: Matrix4.identity()
                            ..scaleByDouble(_scale, _scale, 1.0, 1.0),
                          alignment: Alignment.topLeft,
                          child: RawImage(image: _image, fit: BoxFit.fill),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            IgnorePointer(
              child: CustomPaint(
                size: Size.infinite,
                painter: _OverlayPainter(
                  viewport: _viewportRect,
                  isCircle: widget.isCircle,
                  color: widget.overlayColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final Rect viewport;
  final bool isCircle;
  final Color color;

  _OverlayPainter({
    required this.viewport,
    required this.isCircle,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (viewport == Rect.zero) return;

    final paint = Paint()..color = color;
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutPath = Path();
    if (isCircle) {
      cutoutPath.addOval(viewport);
    } else {
      cutoutPath.addRect(viewport);
    }

    final finalPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    canvas.drawPath(finalPath, paint);

    final borderPaint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    if (isCircle) {
      canvas.drawOval(viewport, borderPaint);
    } else {
      canvas.drawRect(viewport, borderPaint);
    }
  }

  @override
  bool shouldRepaint(_OverlayPainter oldDelegate) {
    return oldDelegate.viewport != viewport ||
        oldDelegate.isCircle != isCircle ||
        oldDelegate.color != color;
  }
}
