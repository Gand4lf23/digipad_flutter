// En lib/screens/tflite/box_widget.dart

import 'package:flutter/material.dart';
import 'package:digipad_flutter/screens/tflite/models/recognition.dart';
import 'package:digipad_flutter/screens/tflite/models/screen_params.dart';

/// Dibuja una caja delimitadora para un resultado de detección.
class BoxWidget extends StatelessWidget {
  final Recognition result;

  const BoxWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    // Obtiene las dimensiones de la pantalla para el escalado.
    final screenH = ScreenParams.screenPreviewSize.height;
    final screenW = ScreenParams.screenPreviewSize.width;

    // El tamaño de la imagen que procesó el modelo (ej. 480x480)
    final modelInputSize = ScreenParams.screenPreviewSize;

    // Escala las coordenadas de la caja desde el tamaño de entrada del modelo
    // al tamaño de la pantalla.
    // IMPORTANTE: Se asume que la aplicación está bloqueada en modo horizontal.
    final scaleX = screenW / modelInputSize.width;
    final scaleY = screenH / modelInputSize.height;

    return Positioned(
      left: result.location.left * scaleX,
      top: result.location.top * scaleY,
      width: result.location.width * scaleX,
      height: result.location.height * scaleY,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          border: Border.all(color: Colors.pink, width: 2.0),
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: FittedBox(
            child: Container(
              color: Colors.pink,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(
                  '${result.label} ${(result.score * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(color: Colors.white, fontSize: 12.0),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
