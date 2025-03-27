# ONNX: TinyYolo-3 flutter example

Object detection for Flutter App using TinyYOLO-3 model.

I referenced these repositories:

- [onnxflutterplay by Andrei Diaconu](https://github.com/andreidiaconu/onnxflutterplay/tree/main)
- [Tiny YOLOv3](https://github.com/onnx/models/tree/main/validated/vision/object_detection_segmentation/tiny-yolov3)

Model is in assets folder and was originally downloaded from [official onnx repository](https://github.com/onnx/models/tree/main/validated/vision/object_detection_segmentation/tiny-yolov3/model)


To run it you need [onnx_runtime package](https://pub.dev/packages/onnxruntime). You can obtain it by running `flutter pub add onnxruntime` or, if you clone this repo, `flutter pub get`


NB: For now this app is hard-coded - the image files need to be set manually.

---

## To-Do List

- [ ] Try to separate code in modules
- [ ] Add access to files & uploading custom images from device




