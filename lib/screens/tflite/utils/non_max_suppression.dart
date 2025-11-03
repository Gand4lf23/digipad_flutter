// lib/screens/tflite/utils/non_max_suppression.dart

import 'dart:math';
import 'dart:ui';

/// Calcula la Intersección sobre la Unión (IoU) de dos cajas.
double calculateIoU(Rect rect1, Rect rect2) {
  final double xA = max(rect1.left, rect2.left);
  final double yA = max(rect1.top, rect2.top);
  final double xB = min(rect1.right, rect2.right);
  final double yB = min(rect1.bottom, rect2.bottom);

  final double intersectionArea = max(0, xB - xA) * max(0, yB - yA);
  final double boxAArea =
      (rect1.right - rect1.left) * (rect1.bottom - rect1.top);
  final double boxBArea =
      (rect2.right - rect2.left) * (rect2.bottom - rect2.top);

  final double iou =
      intersectionArea / (boxAArea + boxBArea - intersectionArea);
  return iou;
}

/// Realiza la Supresión de No Máximos (NMS) para filtrar las cajas superpuestas.
List<int> nonMaxSuppression(
  List<Rect> boxes,
  List<double> scores, {
  double iouThreshold = 0.3,
}) {
  // Ordena los índices de las cajas por sus puntuaciones en orden descendente.
  List<int> indices = List.generate(scores.length, (i) => i);
  indices.sort((a, b) => scores[b].compareTo(scores[a]));

  final List<int> keep = [];
  while (indices.isNotEmpty) {
    final int currentIndex = indices.first;
    keep.add(currentIndex);

    final List<int> remainingIndices = [];
    for (int i = 1; i < indices.length; i++) {
      final int nextIndex = indices[i];
      final double iou = calculateIoU(boxes[currentIndex], boxes[nextIndex]);
      if (iou < iouThreshold) {
        remainingIndices.add(nextIndex);
      }
    }
    indices = remainingIndices;
  }
  return keep;
}
