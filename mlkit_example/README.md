# Google's ML Kit for Flutter | Object detection

Object detection for Flutter App using Google's MLKit object detector (default model).

I referenced these repository:

- [google_ml_kit example app](https://github.com/flutter-ml/google_ml_kit_flutter/tree/master/packages/example)

To run it you need to obtain [dedicated package](https://pub.dev/packages/google_mlkit_object_detection) by running `flutter pub add google_mlkit_object_detection`. If you clone this repo, you can simply run `flutter pub get`

You can also opt for full [google_ml_kit](https://pub.dev/packages/google_ml_kit) which is an umbrella package including all MLKit plugins. You can obtain it by running `flutter pub add google_ml_kit`.


---
## Functions

This app takes picture from gallery and, after running detection, uses a CustomPainter to draw bounding boxes with labels (if any) on that image.

