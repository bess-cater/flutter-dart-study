import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'dart:ui' as ui;

class CustomObjectDetectorPainter extends CustomPainter {
  final List<DetectedObject> objects;
  final ui.Image image;

  CustomObjectDetectorPainter(this.objects, this.image);

  @override
  void paint(Canvas canvas, Size size) {
  

    // Draw the image
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(0, 0, size.width, size.height),
      image: image,
      fit: BoxFit.contain,
    );

    // Get image dimensions
    double inputImageWidth = image.width.toDouble();
    double inputImageHeight = image.height.toDouble();

    // Calculate the scale factors based on the image and canvas size
    double scaleX = size.width / inputImageWidth;
    double scaleY = size.height / inputImageHeight;

    // Draw bounding boxes with scaling
    final paint = Paint()
      ..color = const Color.fromARGB(255, 177, 231, 238)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final textPaint = Paint()
      ..color = const Color.fromARGB(255, 20, 22, 22)
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    final textBackgroundPaint = Paint()
    ..color = const Color.fromARGB(255, 177, 231, 238) // Background color for text
    ..style = PaintingStyle.fill;

    for (var object in objects) {
      Rect bbox = object.boundingBox;

      // Scale the bounding box coordinates
      double left = bbox.left * scaleX;
      double top = bbox.top * scaleY;
      double right = bbox.right * scaleX;
      double bottom = bbox.bottom * scaleY;

      // Create a new scaled bounding box
      Rect scaledBbox = Rect.fromLTRB(left, top, right, bottom);

      // Draw the scaled bounding box
      
      canvas.drawRect(scaledBbox, paint);

      if (object.labels.isNotEmpty) {
        String label = object.labels[0].text; // Use the first label
        TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: const Color.fromARGB(255, 0, 0, 0),
              fontSize: 14,
            ),
          ),
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
        );
        

        textPainter.layout();
        double padding = 1.0; // Padding around the text
        Rect textBackgroundRect = Rect.fromLTWH(
          left,
          bottom-20,
          textPainter.width + 2 * padding,
          textPainter.height + 2 * padding,
        );
        canvas.drawRect(textBackgroundRect, textBackgroundPaint);

        // Draw the label just above the bounding box
        textPainter.paint(canvas, Offset(left + padding, bottom - 20)); // 4 is for padding
      }

      print("Drawing scaled bounding box: $scaledBbox");
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}