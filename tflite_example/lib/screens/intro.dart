import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../utils/processing.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as image_lib;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class ObjectDetector extends StatefulWidget{
  const ObjectDetector({super.key});

  @override
  State<ObjectDetector> createState() => _ObjectDetectorState();
  
}

class _ObjectDetectorState extends State<ObjectDetector>{
  
  
  XFile? _image; 
  final ImagePicker _picker = ImagePicker();
  late ImageProcessor _imageProcessor;
  ui.Image? _realImage;
  ui.Image? _displayImage;
  List<int>? _labelsIndex;
  late List<String> text_labels;

  static final labelColors = [
    -16777216,
    -8388608,
    -16744448,
    -8355840,
    -16777088,
    -8388480,
    -16744320,
    -8355712,
    -12582912,
    -4194304,
    -12550144,
    -4161536,
    -12582784,
    -4194176,
    -12550016,
    -4161408,
    -16760832,
    -8372224,
    -16728064,
    -8339456,
    -16760704
  ];

  _loadLabel() async {
    final labelString = await rootBundle.loadString('assets/labelmap.txt');
    text_labels = labelString.split('\n');
  }

  @override
  void initState() {
    super.initState();
    _imageProcessor = ImageProcessor(); // Initialize it here
    
  }


  Future getImage() async {
    await _loadLabel();
    //pickedFile에 ImagePicker로 가져온 이미지가 담긴다.
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path);
      });
    }}

  getLabelsName(int index) {
    return text_labels[index];
  }

  Future processImage() async{
    await getImage();
    if (_image != null) { 
    final masks = await _imageProcessor.processImage(_image!);
    _postprocess(masks!, _image!);
    print("Processing complete: $masks");
  } else {
    print("No image selected");
  }
  }

  Future _postprocess(List<List<List<double>>> masks, XFile img) async {
    if (masks == null) return null;
    
    // Load original image
    Uint8List imageBytes = await img.readAsBytes();
    image_lib.Image? originalImage = image_lib.decodeImage(imageBytes);
    if (originalImage == null) throw Exception("Failed to decode image");

    // Get dimensions
    final originImageWidth = originalImage.width;
    final originImageHeight = originalImage.height;

    // Create mask image with model output dimensions
    final width = masks.length;
    final height = masks[0].length;
    List<int> imageMatrix = List.filled(width * height * 4, 0);
    final labelsIndex = <int>{};

    // Process the masks in correct order
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final List<double> score = masks[x][y];
        
        // Find max score index
        int maxIndex = 0;
        double maxScore = score[0];
        for (int k = 1; k < score.length; k++) {
          if (score[k] > maxScore) {
            maxScore = score[k];
            maxIndex = k;
          }
        }
        labelsIndex.add(maxIndex);

        // Calculate pixel index in output image - NO FLIP in Y coordinate
        final pixelIndex = (y * width + x) * 4;  // Removed the flip calculation
        
        if (maxIndex == 0) {
          imageMatrix[pixelIndex + 3] = 0; // Transparent background
          continue;
        }

        // Apply color
        final color = labelColors[maxIndex];
        imageMatrix[pixelIndex] = (color >> 16) & 0xFF;     // R
        imageMatrix[pixelIndex + 1] = (color >> 8) & 0xFF;  // G
        imageMatrix[pixelIndex + 2] = color & 0xFF;         // B
        imageMatrix[pixelIndex + 3] = 127;                  // Alpha
      }
    }

    // Create mask image
    image_lib.Image maskImage = image_lib.Image.fromBytes(
      width: width,
      height: height,
      bytes: Uint8List.fromList(imageMatrix).buffer,
      numChannels: 4,
    );

    // Resize mask to match original image
    final resizedMask = image_lib.copyResize(
      maskImage,
      width: originImageWidth,
      height: originImageHeight,
      interpolation: image_lib.Interpolation.nearest
    );

    // Convert images for display
    final maskBytes = image_lib.encodePng(resizedMask);
    final maskCodec = await ui.instantiateImageCodec(maskBytes);
    final maskFrame = await maskCodec.getNextFrame();

    final originalCodec = await ui.instantiateImageCodec(imageBytes);
    final originalFrame = await originalCodec.getNextFrame();

    setState(() {
      _realImage = originalFrame.image;
      _displayImage = maskFrame.image;
      _labelsIndex = labelsIndex.toList();
    });
  }

    // final masks =
    //     await _imageSegmentationHelper.inferenceCameraFrame(cameraImage);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Text("Image segmentation", style: TextStyle(
              fontSize: 24.0,
            ),),
          ),
          ElevatedButton.icon(
            onPressed: () async { processImage(); },
            icon: Icon(Icons.upload),
            label: Text("Choose from gallery..."),
          ),

          // Image display container
          SizedBox(
            height: 300,
            width: double.infinity,
            child: Center(
              child: _realImage != null ? Stack(
                alignment: Alignment.center,
                children: [
                  // Base image
                  RawImage(
                    image: _realImage,
                    fit: BoxFit.contain,
                  ),
                  // Overlay mask
                  if (_displayImage != null)
                    Positioned.fill(
                      child: RawImage(
                        image: _displayImage,
                        fit: BoxFit.contain,
                      ),
                    ),
                ],
              ) : Container(),
            ),
          ),

          // Labels list
          if (_labelsIndex != null)
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: Set.from(_labelsIndex!).length, // Show unique labels only
                itemBuilder: (context, index) {
                  final uniqueLabels = Set.from(_labelsIndex!).toList();
                  return Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(labelColors[uniqueLabels[index]]).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      getLabelsName(uniqueLabels[index]),
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
  
}

class OverlayPainter extends CustomPainter {
  final ui.Image image;
  OverlayPainter(this.image);
  
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(covariant OverlayPainter oldDelegate) {
    return oldDelegate.image != image;
  }
}