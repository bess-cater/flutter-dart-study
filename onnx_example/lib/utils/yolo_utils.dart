import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui; 
// import 'package:image/image.dart' as img;

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<double> boxes; // Bounding box [centerX, centerY, width, height]
  final ui.Image imageM;

  BoundingBoxPainter({required this.boxes, required this.imageM});

  @override
  void paint(Canvas canvas, Size size) {
    print("painting...");

    // Define max width and height for the container
    double maxWidth = size.width;
    double maxHeight = size.height;

    // Calculate scale factor to fit image into the container without distortion
    double scaleFactor = maxWidth / imageM.width;
    double scaledWidth = imageM.width * scaleFactor;
    double scaledHeight = imageM.height * scaleFactor;

    // If the scaled height exceeds maxHeight, adjust the scaling based on height
    if (scaledHeight > maxHeight) {
      scaleFactor = maxHeight / imageM.height;
      scaledWidth = imageM.width * scaleFactor;
      scaledHeight = imageM.height * scaleFactor;
    }

    // Paint object for the image
    Paint paint = Paint();

    // Draw the image in the container size, maintaining aspect ratio
    canvas.drawImageRect(
      imageM,
      Rect.fromLTWH(0, 0, imageM.width.toDouble(), imageM.height.toDouble()),
      Rect.fromLTWH(0, 0, scaledWidth, scaledHeight),
      paint,
    );

    // Paint settings for bounding boxes
    Paint boxPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Unwrap the bounding boxes
    double centerX = boxes[0];
    double centerY = boxes[1];
    double width = boxes[2];
    double height = boxes[3];

    // Adjust bounding box coordinates to the scaled image
    double xMin = (centerX - width / 2) * scaleFactor;
    double yMin = (centerY - height / 2) * scaleFactor;
    double xMax = (centerX + width / 2) * scaleFactor;
    double yMax = (centerY + height / 2) * scaleFactor;

    // Draw the bounding box on the scaled image
    canvas.drawRect(Rect.fromLTRB(xMin, yMin, xMax, yMax), boxPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}