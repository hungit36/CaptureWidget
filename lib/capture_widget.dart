import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

abstract class CaptureService {
  static final _instance = _AnalyticsUtils();
  static CaptureService get instance => CaptureService._instance;

  GlobalKey<OverRepaintBoundaryState> get globalKey => instance.globalKey;

  Future<Uint8List?> captureImage();

}

class _AnalyticsUtils extends CaptureService {
  @override
  final GlobalKey<OverRepaintBoundaryState> globalKey = GlobalKey();

  @override
  Future<Uint8List?> captureImage() async {
    var renderObject = globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (renderObject == null) return null;

    final captureImage = await renderObject.toImage();
    final bytesData = await captureImage.toByteData(format: ImageByteFormat.png);
    if (bytesData == null) return null;
    final bytes = bytesData.buffer.asUint8List();
    if (bytes.isEmpty) return null;
    return bytes;
  }
}

class UiImagePainter extends CustomPainter {
  final ui.Image image;

  UiImagePainter(this.image);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    // simple aspect fit for the image
    var hr = size.height / image.height;
    var wr = size.width / image.width;

    double ratio;
    double translateX;
    double translateY;
    if (hr < wr) {
      ratio = hr;
      translateX = (size.width - (ratio * image.width)) / 2;
      translateY = 0.0;
    } else {
      ratio = wr;
      translateX = 0.0;
      translateY = (size.height - (ratio * image.height)) / 2;
    }

    canvas.translate(translateX, translateY);
    canvas.scale(ratio, ratio);
    canvas.drawImage(image, const Offset(0.0, 0.0), Paint());
  }

  @override
  bool shouldRepaint(UiImagePainter oldDelegate) {
    return oldDelegate.image != image;
  }
}

class UiImageDrawer extends StatelessWidget {
  final ui.Image image;

  const UiImageDrawer({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: UiImagePainter(image),
    );
  }
}

class CaptureWidget extends StatelessWidget {

  final Widget child;
  static final Random random = Random();

  final GlobalKey<OverRepaintBoundaryState> overRepaintKey;

  const CaptureWidget({super.key, required this.child, required this.overRepaintKey});

  @override
  Widget build(BuildContext context) {
    return OverRepaintBoundary(
      key: overRepaintKey,
      child: RepaintBoundary(
        child: child,
      ),
    );
  }
}

class OverRepaintBoundary extends StatefulWidget {
  final Widget child;

  const OverRepaintBoundary({super.key, required this.child});

  @override
  OverRepaintBoundaryState createState() => OverRepaintBoundaryState();
}

class OverRepaintBoundaryState extends State<OverRepaintBoundary> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}