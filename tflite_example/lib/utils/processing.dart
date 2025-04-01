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
    await _loadModel();
    
    Uint8List imageBytes = await imgFile.readAsBytes();
    image_lib.Image? image = image_lib.decodeImage(imageBytes);
    if (image == null) return null;

    _inputShape = _interpreter.getInputTensor(0).shape;
    _outputShape = _interpreter.getOutputTensor(0).shape;

    // First resize to model input size
    var resizedImage = image_lib.copyResize(
      image,
      width: _inputShape[1],
      height: _inputShape[2],
    );

    // Create the input matrix with correct dimensions [height][width][channels]
    final imageMatrix = List.generate(
      _inputShape[1], // width
      (x) => List.generate(
        _inputShape[2], // height
        (y) {
          final pixel = resizedImage.getPixel(x, y);
          // normalize -1 to 1
          return [
            (pixel.r - 127.5) / 127.5,
            (pixel.g - 127.5) / 127.5,
            (pixel.b - 127.5) / 127.5
          ];
        },
      ),
    );
    final input = [imageMatrix];
    
    final output = [
      List.generate(
        _outputShape[1],
        (x) => List.generate(
          _outputShape[2],
          (y) => List.filled(_outputShape[3], 0.0),
        ),
      )
    ];

    _interpreter.run(input, output);
    return output.first;
  }
  
}