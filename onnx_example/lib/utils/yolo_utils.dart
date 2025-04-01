import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:math' as math;

class BoundingBoxPainter extends CustomPainter {
  final List<double> boxes;  // Back to single box
  final ui.Image imageM;

  BoundingBoxPainter({required this.boxes, required this.imageM});

  @override
  void paint(Canvas canvas, Size size) {
    print("painting...");
    print("Canvas size: $size");
    print("Image size: ${imageM.width}x${imageM.height}");
    print("Original box: $boxes");

    // Draw the image first
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(0, 0, size.width, size.height),
      image: imageM,
      fit: BoxFit.contain,
    );

    // Calculate actual displayed image size
    double imageAspectRatio = imageM.width / imageM.height;
    double canvasAspectRatio = size.width / size.height;
    
    double displayedImageWidth;
    double displayedImageHeight;
    
    if (imageAspectRatio > canvasAspectRatio) {
      displayedImageWidth = size.width;
      displayedImageHeight = size.width / imageAspectRatio;
    } else {
      displayedImageHeight = size.height;
      displayedImageWidth = size.height * imageAspectRatio;
    }

    double dx = (size.width - displayedImageWidth) / 2;
    double dy = (size.height - displayedImageHeight) / 2;

    // YOLO coordinates are relative to 416x416 input
    final yoloInputSize = 416.0;
    
    // First convert YOLO coordinates (416x416) to relative coordinates (0-1)
    double relX1 = boxes[0] / yoloInputSize;
    double relY1 = boxes[1] / yoloInputSize;
    double relX2 = boxes[2] / yoloInputSize;
    double relY2 = boxes[3] / yoloInputSize;

    // Then scale to displayed image size and add offset
    double x1 = relX1 * displayedImageWidth + dx;
    double y1 = relY1 * displayedImageHeight + dy;
    double x2 = relX2 * displayedImageWidth + dx;
    double y2 = relY2 * displayedImageHeight + dy;

    // Ensure coordinates stay within image bounds
    x1 = math.max(dx, math.min(dx + displayedImageWidth, x1));
    y1 = math.max(dy, math.min(dy + displayedImageHeight, y1));
    x2 = math.max(dx, math.min(dx + displayedImageWidth, x2));
    y2 = math.max(dy, math.min(dy + displayedImageHeight, y2));

    print("Drawing box at:");
    print("Top-left: ($x1, $y1)");
    print("Bottom-right: ($x2, $y2)");
    print("Display image size: ${displayedImageWidth}x${displayedImageHeight}");
    print("Offset: ($dx, $dy)");

    final boxPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw the box using corner coordinates
    canvas.drawRect(
      Rect.fromLTRB(x1, y1, x2, y2),
      boxPaint
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
