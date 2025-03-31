import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';

class ImageProcessor{

  late Interpreter _interpreter;
  late List<int> _inputShape;
  late List<int> _outputShape;

   _loadModel() async {
    final options = InterpreterOptions();
    _interpreter = await Interpreter.fromAsset('assets/deeplabv3.tflite',
        options: options);
  }

  Future<List<List<List<double>>>?> processImage(XFile imgFile) async{
    _loadModel();
    
    Uint8List imageBytes = await imgFile.readAsBytes();
    // Decode image using image package
    image_lib.Image? image = image_lib.decodeImage(imageBytes);
    if (Platform.isAndroid) {
        image = image_lib.copyRotate(image!, angle: 90);
      }
      _inputShape = _interpreter.getInputTensor(0).shape;
      _outputShape = _interpreter.getOutputTensor(0).shape;

      // resize original image to match model shape.
      image = image_lib.copyResize(
        image!,
        width: _inputShape[1],
        height: _inputShape[2],
      );

      final imageMatrix = List.generate(
        image.height,
        (y) => List.generate(
          image!.width,
          (x) {
            final pixel = image!.getPixel(x, y);
            // normalize -1 to 1
            return [
              (pixel.r - 127.5) / 127.5,
              (pixel.b - 127.5) / 127.5,
              (pixel.g - 127.5) / 127.5
            ];
          },
        ),
      );

      // Set tensor input [1, 257, 257, 3]
      final input = [imageMatrix];
      // Set tensor output [1, 257, 257, 21]
      final output = [
        List.filled(
            _outputShape[1],
            List.filled(_outputShape[2],
                List.filled(_outputShape[3], 0.0)))
      ];
      print("ggg");
      _interpreter.run(input, output);
      // Get first output tensor
      final result = output.first;

      return result;

  }
  
}