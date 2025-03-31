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

  Future _postprocess(List<List<List<double>>> masks, XFile img)
  async {
    if (masks == null) return null;
    final width = masks.length;
    final height = masks.first.length;
    // store image matrix
    List<int> imageMatrix = [];
    // store labels index to display on screen
    final labelsIndex = <int>{};

    for (int i = 0; i < width; i++) {
      final List<List<double>> row = masks[i];
      for (int j = 0; j < height; j++) {
        final List<double> score = row[j];
        // find index of max score
        int maxIndex = 0;
        double maxScore = score[0];
        for (int k = 1; k < score.length; k++) {
          if (score[k] > maxScore) {
            maxScore = score[k];
            maxIndex = k;
          }
        }
        labelsIndex.add(maxIndex);

        if (maxIndex == 0) {
          imageMatrix.addAll([0, 0, 0, 0]);
          continue;
        }

        // get color from label color
        final color = labelColors[maxIndex];
        // convert color to r,g,b
        final r = (color & 0x00ff0000) >> 16;
        final g = (color & 0x0000ff00) >> 8;
        final b = (color & 0x000000ff);
        // alpha 50%
        imageMatrix.addAll([r, g, b, 127]);
      }
    }

    // convert image matrix to image
    image_lib.Image convertedImage = image_lib.Image.fromBytes(
        width: width,
        height: height,
        bytes: Uint8List.fromList(imageMatrix).buffer,
        numChannels: 4);
    
  Uint8List imageBytes = await img.readAsBytes();

  // Step 2: Decode image into image_lib.Image
  image_lib.Image? originalImage = image_lib.decodeImage(imageBytes);
  if (originalImage == null) throw Exception("Failed to decode image");

  // Step 2: Decode the PNG into a ui.Image
  ui.Codec codec2 = await ui.instantiateImageCodec(imageBytes);
  ui.FrameInfo realFrame = await codec2.getNextFrame();
  

  int originImageWidth = originalImage.width;
  int originImageHeight = originalImage.height;
  print(originImageWidth);
  print(originImageHeight);

    // resize output image to match original image
    final resizeImage = image_lib.copyResize(convertedImage,
        width: originImageWidth, height: originImageHeight);

    // convert image to ui.Image to display on screen
    final bytes = image_lib.encodePng(resizeImage);
    ui.Codec codec = await ui.instantiateImageCodec(bytes);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    setState(() {
      _displayImage = frameInfo.image;
      _labelsIndex = labelsIndex.toList();
      _realImage = realFrame.image;

    });
  }

    // final masks =
    //     await _imageSegmentationHelper.inferenceCameraFrame(cameraImage);

  @override
  Widget build(BuildContext context) {
    var scale = 1.0;
    if (_displayImage != null) {
      final minOutputSize = _displayImage!.width > _displayImage!.height
          ? _displayImage!.height
          : _displayImage!.width;
      final minScreenSize =
          MediaQuery.of(context).size.width > MediaQuery.of(context).size.height
              ? MediaQuery.of(context).size.height
              : MediaQuery.of(context).size.width;
      scale = minScreenSize / minOutputSize;}
    return Scaffold(
  backgroundColor: Colors.white,
  body: Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Text("Image segmentation"),
      ElevatedButton.icon(
        onPressed: () async { processImage(); }, 
        icon: Icon(Icons.upload),
        label: Text("Choose from gallery..."),
      ),

      // Containing the image inside a field with height 300
      SizedBox(
        height: 300, // Fixed height for the container
        width: double.infinity, // Make it take full width
        child: Center( // Centers the Stack content
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_realImage != null)
                RawImage(
                  image: _realImage,
                  fit: BoxFit.contain, // Ensures it fits inside the box
                ),

              if (_displayImage != null)
                SizedBox(
                  width: _realImage!.width.toDouble(),
                  height: _realImage!.height.toDouble(),
                  child: CustomPaint(
                    painter: OverlayPainter(_displayImage!),
                  ),
                ),
            ],
          ),
        ),
      ),

      if (_labelsIndex != null)
        Align(
          alignment: Alignment.bottomCenter,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _labelsIndex!.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(labelColors[_labelsIndex![index]]).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  getLabelsName(_labelsIndex![index]),
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