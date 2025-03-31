import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:image_picker/image_picker.dart';

import 'utils.dart';

class GalleryView extends StatefulWidget {
  const GalleryView({
    super.key,
    required this.title,
    this.text,
    required this.onImage,
    this.customPaint,
  });

  final String title;
  final String? text;
  final Function(InputImage inputImage, ui.Image uiImage) onImage;
  final CustomPaint? customPaint;

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  File? _image;
  String? _path;
  ImagePicker? _imagePicker;

  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: _galleryBody(),
    );
  }

  Widget _galleryBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ListView(
          shrinkWrap: true,
          children: [
            _image != null
                ? SizedBox(
                    height: 400,
                    width: 400,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        Image.file(_image!),
                        if (widget.customPaint != null) widget.customPaint!,
                      ],
                    ),
                  )
                : Icon(
                    Icons.upload,
                    size: 100,
                  ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 100),
              child: ElevatedButton.icon(
                icon: Icon(Icons.upload),
                label: Text('Upload image'),
                onPressed: () => _getImage(ImageSource.gallery),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _getImage(ImageSource source) async {
    setState(() {
      _image = null;
      _path = null;
    });
    final pickedFile = await _imagePicker?.pickImage(source: source);
    if (pickedFile != null) {
      _processFile(pickedFile.path);
    }
  }

  Future<void> _processFile(String path) async {
    setState(() {
      _image = File(path);
      _path = path;
    });
    final inputImage = InputImage.fromFilePath(path);
    final ui.Image uiImage = await _loadUiImage(path);
    widget.onImage(inputImage, uiImage);
  }

  Future<ui.Image> _loadUiImage(String path) async {
    final Uint8List imageBytes = await File(path).readAsBytes();
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(imageBytes, (ui.Image img) {
      completer.complete(img);
    });
    return completer.future;
  }
}
