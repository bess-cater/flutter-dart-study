import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

import 'detector_view.dart';
import '../painters/default_painter.dart';
import 'utils.dart';
import '../painters/custompainter.dart';
import 'dart:ui' as ui;

class ObjectDetectorView extends StatefulWidget {
  @override
  State<ObjectDetectorView> createState() => _ObjectDetectorView();
}

class _ObjectDetectorView extends State<ObjectDetectorView> {
  ObjectDetector? _objectDetector;
  DetectionMode _mode = DetectionMode.single;
  bool _canProcess = false;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.back;


  @override
  void dispose() {
    _canProcess = false;
    _objectDetector?.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeDetector();  // Ensure detector is initialized when the widget is first created
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        DetectorView(
          title: 'Object Detection',
          customPaint: _customPaint,
          text: _text,
          onImage: _processImage,  // Pass _processImage as the callback here
        ),
      ]),
    );
  }

  

  void _initializeDetector() async {
    _objectDetector?.close();
    _objectDetector = null;
    // use the default model
    print('use the default model');
    final options = ObjectDetectorOptions(
      mode: _mode,
      classifyObjects: true,
      multipleObjects: true,
    );
    _objectDetector = ObjectDetector(options: options);
    _canProcess = true;
  }

  Future<void> _processImage(InputImage inputImage, ui.Image uiImage) async {
    print("processing.....");
    if (_objectDetector == null) {
      print("no detector!!!");
      return;
    }
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final objects = await _objectDetector!.processImage(inputImage);
    print('Objects found: ${objects.length}\n\n');
    // DetectedObject class;
    // properties: boundingBox, labels
    for(DetectedObject obj in objects){
      print("=========================");
      List<Label> labels = obj.labels;
      for (Label label in labels){
        print(label.text);
      }
      Rect bbox = obj.boundingBox;
      print(bbox.toString());
    }

    if (objects.isNotEmpty) {
      final painter = CustomObjectDetectorPainter(
        objects,
        uiImage, // Pass the ui.Image here
      );

      setState(() {
        _customPaint = CustomPaint(painter: painter); // Update the customPaint state here
      });
    }

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}