// import 'package:camera/camera.dart';
// import 'package:flutter_tflite/flutter_tflite.dart';

// /// Lightweight wrapper around the `tflite` plugin to load a model
// /// and perform object detection on camera frames.
// class TfliteService {
//   /// Loads a TensorFlow Lite model (and optional labels) from assets.
//   /// Defaults to your custom model path under `assets/models/`.
//   static Future<String?> loadModel({
//     String model = 'assets/models/model.tflite',
//     String? labels,
//     int numThreads = 1,
//     bool isAsset = true,
//     bool useGpuDelegate = false,
//   }) async {
//     // Only pass labels when provided to avoid nullability errors
//     if (labels != null) {
//       return Tflite.loadModel(
//         model: model,
//         labels: labels,
//         numThreads: numThreads,
//         isAsset: isAsset,
//         useGpuDelegate: useGpuDelegate,
//       );
//     }

//     return Tflite.loadModel(
//       model: model,
//       numThreads: numThreads,
//       isAsset: isAsset,
//       useGpuDelegate: useGpuDelegate,
//     );
//   }

//   /// Runs object detection on a single camera frame.
//   /// For YOLO/SSD MobileNet, use this method and tune `threshold` & `numResultsPerClass`.
//   static Future<List?> detectOnFrame({
//     required CameraImage image,
//     double imageMean = 127.5,
//     double imageStd = 127.5,
//     int rotation = 90,
//     int numResultsPerClass = 2,
//     double threshold = 0.4,
//     bool asynch = true,
//   }) async {
//     return Tflite.detectObjectOnFrame(
//       bytesList: image.planes.map((p) => p.bytes).toList(),
//       imageHeight: image.height,
//       imageWidth: image.width,
//       imageMean: imageMean,
//       imageStd: imageStd,
//       rotation: rotation,
//       numResultsPerClass: numResultsPerClass,
//       threshold: threshold,
//       asynch: asynch,
//     );
//   }

//   /// Closes and releases TFLite resources.
//   static Future<void> close() => Tflite.close();
// }
