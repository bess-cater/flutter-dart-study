import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart' show rootBundle;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'utils/yolo_utils.dart';

void main() {
  runApp(const MyApp());
}

//App
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

//MyHomePage = has state!

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  // IMage we are going to get!
  ui.Image? image;

  String? message;
  String? message2;

  List<double>? _bboxes;
  ui.Image? _image; // Image to display
  double imageWidth = 400.0; // Example image width (pass the actual width)
  double imageHeight = 300.0; // Example image height (pass the actual height)

  void _runModel() {
    // Here comes the model itself!
    _runYolo();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 400,
              height: 400,
              child:
              _image == null || _bboxes == null
            ? CircularProgressIndicator() // Show loading indicator if not ready
            : CustomPaint(
                size: Size(_image!.width.toDouble(), _image!.height.toDouble()),
                painter: BoundingBoxPainter(
                  boxes: _bboxes!,
                  imageM: _image!,
                ),
              ),

            ),
            
      
            // if (_bboxes != null && image != null)
            
            // CustomPaint(
            //   painter: BoundingBoxPainter(
            //     boxes: _bboxes!, // Use the non-null _bboxes safely
            //     imageM: image!,
            //   ),
            // ),
          
            if (message != null)
              Text(
                'I think it is: $message (${message2}% sure!)', 
                style: TextStyle(fontSize: 24, color: const ui.Color.fromARGB(255, 219, 109, 214)),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _runModel,
        tooltip: 'Run ONNX model',
        child: const Icon(Icons.play_arrow),
      ),
    );
  } //end of build method!!!
 
    Future<Map<String, dynamic>> processImage(Uint8List imageBytes, {
  int targetHeight = 416, 
  int targetWidth = 416,
  double paddingValue = 128.0 / 255.0
}) async {
  // Decode image
  final image = await decodeImageFromList(imageBytes);
  final originalWidth = image.width;
  final originalHeight = image.height;
  
  List<double> imageSize = [originalHeight.toDouble(), originalWidth.toDouble()];

  // Maintain aspect ratio
  final scale = math.min(targetWidth / originalWidth, targetHeight / originalHeight);
  final newWidth = (scale * originalWidth).floor();
  final newHeight = (scale * originalHeight).floor();

  final pictureRecorder = ui.PictureRecorder();
  final canvas = ui.Canvas(pictureRecorder, ui.Rect.fromPoints(
    ui.Offset.zero, ui.Offset(targetWidth.toDouble(), targetHeight.toDouble())
  ));

  // Fill background with padding color (128,128,128)
  final paintBackground = ui.Paint()..color = ui.Color.fromARGB(255, 128, 128, 128);
  canvas.drawRect(
    ui.Rect.fromLTWH(0, 0, targetWidth.toDouble(), targetHeight.toDouble()), 
    paintBackground
  );

  // Draw the image centered
  final left = ((targetWidth - newWidth) / 2).floor();
  final top = ((targetHeight - newHeight) / 2).floor();
  final paintImage = ui.Paint()..filterQuality = ui.FilterQuality.high;
  canvas.drawImageRect(
    image,
    ui.Rect.fromLTWH(0, 0, originalWidth.toDouble(), originalHeight.toDouble()),
    ui.Rect.fromLTWH(left.toDouble(), top.toDouble(), newWidth.toDouble(), newHeight.toDouble()),
    paintImage
  );

  // Get processed image
  final processedPicture = pictureRecorder.endRecording();
  final processedImage = await processedPicture.toImage(targetWidth, targetHeight);
  final byteData = await processedImage.toByteData(format: ui.ImageByteFormat.rawRgba);
  final rgbaUints = Uint8List.view(byteData!.buffer);

  // Normalize pixel values and reorder channels from RGBA to CHW (C=3, H=416, W=416)
  final indexed = rgbaUints.indexed;
  final imageData = [
    ...indexed.where((e) => e.$1 % 4 == 0).map((e) => e.$2 / 255.0), // R
    ...indexed.where((e) => e.$1 % 4 == 1).map((e) => e.$2 / 255.0), // G
    ...indexed.where((e) => e.$1 % 4 == 2).map((e) => e.$2 / 255.0), // B
  ];

  return {
    'image_data': imageData,
    'image_size': imageSize,
  };
}


  void _runYolo() async {


    OrtEnv.instance.init();
    print("0         0--------------------");
    final sessionOptions = OrtSessionOptions();
    
    // Load ONNX model
    final rawAssetFile = await rootBundle.load("assets/models/tiny-yolov3-11.onnx");
    print("0         1--------------------");
    final bytes = rawAssetFile.buffer.asUint8List();
    final session = OrtSession.fromBuffer(bytes, sessionOptions);
    final runOptions = OrtRunOptions();

    ByteData blissBytes = await rootBundle.load('assets/cake.jpg');
    print("0         2--------------------");
  
  // Convert ByteData to Uint8List
    final imageBytes = Uint8List.sublistView(blissBytes);

    final byteData = blissBytes.buffer.asUint8List();
    final imgN = await decodeImageFromList(byteData); // Decode image from byte data
    setState(() {
      _image = imgN as ui.Image; // Assign the decoded image to the image variable
    });

    final preInputs = await processImage(imageBytes);
    print("6--------------------");
    List<double> imgSize = preInputs["image_size"];
    List<double> img = preInputs["image_data"];

    final inputOrt = OrtValueTensor.createTensorWithDataList(Float32List.fromList(img), [1, 3, 416, 416]);
    final inputSize = OrtValueTensor.createTensorWithDataList(Float32List.fromList(imgSize), [1, 2]);
    print("7--------------------");
    // Run model
    final inputs = {'input_1': inputOrt, "image_shape": inputSize};
    // THIS IS IMPORTANT!!!!!!  print(session.inputNames[0]);
    final outputs = session.run(runOptions, inputs);
    //  Gets through well!!!!!
    print("8--------------------");
    OrtValue? boxes = outputs[0];
    OrtValue?  scores = outputs[1];
    OrtValue? indices = outputs[2];
    List<double> bboxes = await postProcessModelOutputs(boxes, scores, indices);
    
    // Clean up resources
    inputOrt.release();
    runOptions.release();
    sessionOptions.release();
    OrtEnv.instance.release();

  
    
}

  Future<List<double>> postProcessModelOutputs(OrtValue? boxesTensor, OrtValue? scoresTensor, OrtValue? indicesTensor) async {
  // Extract raw data from OrtValue tensors
  if (boxesTensor == null || scoresTensor == null || indicesTensor == null) {
    print("Error: One or more tensors are null.");
    // return []; 
    throw ArgumentError("Error: One or more tensors are null.");
  }
  final boxes = boxesTensor.value as List<List<List<double>>>;  // Shape: [1, n_candidates, 4]
  print("heh");
  final scores = scoresTensor.value as List<List<List<double>>>;  
  print("heh2");     // Shape: [1, 80, n_candidates]
  final indices = indicesTensor.value as List<List<List<int>>>;      
  print("heh3");       // Shape: [nbox, 3]
  List<String> classNames = [
  "person", "bicycle", "car", "motorbike", "aeroplane", "bus", "train", "truck", "boat",
  "traffic light", "fire hydrant", "stop sign", "parking meter", "bench",
  "bird", "cat", "dog", "horse", "sheep", "cow", "elephant", "bear",
  "zebra", "giraffe", "backpack", "umbrella", "handbag", "tie", "suitcase",
  "frisbee", "skis", "snowboard", "sports ball", "kite", "baseball bat",
  "baseball glove", "skateboard", "surfboard", "tennis racket", "bottle",
  "wine glass", "cup", "fork", "knife", "spoon", "bowl", "banana", "apple",
  "sandwich", "orange", "broccoli", "carrot", "hot dog", "pizza", "donut",
  "cake", "chair", "sofa", "pottedplant", "bed", "diningtable", "toilet",
  "tvmonitor", "laptop", "mouse", "remote", "keyboard", "cell phone",
  "microwave", "oven", "toaster", "sink", "refrigerator", "book", "clock",
  "vase", "scissors", "teddy bear", "hair drier", "toothbrush"
];
  print(boxes[0][0].length);
  
    double maxConf = 0;
    int bestClass = -1;
    int bestBoxIndex = -1;

    for (int classIdx = 0; classIdx < scores[0].length; classIdx++){
    
      for (int boxId = 0; boxId < scores[0][classIdx].length; boxId++){
        
        if(scores[0][classIdx][boxId] > maxConf){
          maxConf = scores[0][classIdx][boxId];
          bestBoxIndex = boxId;
          bestClass = classIdx;
      }
      }
      if(maxConf>0.05){
        print("For class ***${classNames[classIdx]}");
        print("Max confidence is $maxConf");}
      
    }
    String detectedClass = classNames[bestClass];
    // print(boxes[0][bestBoxIndex][0]);
    // print(boxes[0][bestBoxIndex][1]);
    // print(boxes[0][bestBoxIndex][2]);
    // print(boxes[0][bestBoxIndex][3]);

    setState(() {
      message = detectedClass;
      message2 = (maxConf*100.0).toStringAsFixed(2);
      _bboxes = boxes[0][bestBoxIndex];
    });

    return boxes[0][bestBoxIndex];


}





  //!!!!!!! <-----IMportant------>!!!!!!!


Future<OrtValueTensor> preprocessImage(ui.Image image, {int targetSize = 416}) async {
  // Convert image to ByteData
  final ByteData? imageBytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (imageBytes == null) {
    throw Exception('Failed to convert image to ByteData');
  }

  // Convert to Uint8List
  final Uint8List rgbaBytes = Uint8List.view(imageBytes.buffer);
  print("1--------------------");
  // Create a dart:ui Image from the original image
  final codec = await ui.instantiateImageCodec(
    rgbaBytes, 
    targetWidth: targetSize, 
    targetHeight: targetSize
  );
  final frame = await codec.getNextFrame();
  final resizedImage = frame.image;

  // Convert resized image to byte data
  final ByteData? resizedBytes = await resizedImage.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (resizedBytes == null) {
    throw Exception('Failed to convert resized image to ByteData');
  }

  final Uint8List resizedRgbaBytes = Uint8List.view(resizedBytes.buffer);

  // Convert RGBA to separate RGB channels
  final Uint8List processedImageBytes = Uint8List(targetSize * targetSize * 3);
  print("2--------------------");
  for (int i = 0; i < targetSize * targetSize; i++) {
    final rgbaIndex = i * 4;
    final rgbIndex = i * 3;
    
    // Extract RGB from RGBA (skipping alpha)
    processedImageBytes[rgbIndex] = resizedRgbaBytes[rgbaIndex];     // R
    processedImageBytes[rgbIndex + 1] = resizedRgbaBytes[rgbaIndex + 1]; // G
    processedImageBytes[rgbIndex + 2] = resizedRgbaBytes[rgbaIndex + 2]; // B
  }

  // Optional: Normalize to [0, 1] if required by your model
  final Float32List normalizedBytes = Float32List(targetSize * targetSize * 3);
  for (int i = 0; i < processedImageBytes.length; i++) {
    normalizedBytes[i] = processedImageBytes[i] / 255.0;
  }

  // Create tensor with the processed image
  final shape = [1, targetSize, targetSize, 3]; // NHWC format
  print("4--------------------");
  return OrtValueTensor.createTensorWithDataList(normalizedBytes, shape);
}


//as written by ChatGPT!!!
  Future<OrtValueTensor> imageToUint8Tensor(ui.Image image) async {
  // Convert image to RGBA byte data
  final imageAsBytes = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
  final rgbaUints = Uint8List.view(imageAsBytes.buffer);

  final width = image.width;
  final height = image.height;

  // Rearrange to match ONNX format (NCHW or NHWC)
  final Uint8List imageBytes = Uint8List(width * height * 3); // Only RGB

  for (int i = 0; i < width * height; i++) {
    final rgbaIndex = i * 4;
    final rgbIndex = i * 3;
    imageBytes[rgbIndex] = rgbaUints[rgbaIndex]; // R
    imageBytes[rgbIndex + 1] = rgbaUints[rgbaIndex + 1]; // G
    imageBytes[rgbIndex + 2] = rgbaUints[rgbaIndex + 2]; // B
  }

  final shape = [1, height, width, 3]; // NHWC format
  return OrtValueTensor.createTensorWithDataList(imageBytes, shape);
}

  Future<List<double>> imageToFloatTensor(ui.Image image) async {
    final imageAsFloatBytes = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    final rgbaUints = Uint8List.view(imageAsFloatBytes.buffer);

    final indexed = rgbaUints.indexed;
    return [
    ...indexed.where((e) => e.$1 % 4 == 0).map((e) => e.$2.toDouble()),
    ...indexed.where((e) => e.$1 % 4 == 1).map((e) => e.$2.toDouble()),
    ...indexed.where((e) => e.$1 % 4 == 2).map((e) => e.$2.toDouble()),
    ];
  }

  
  
}
