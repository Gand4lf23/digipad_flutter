// lib/screens/tflite/stats_widget.dart
import 'package:flutter/material.dart';

class StatsWidget extends StatelessWidget {
  final String title;
  final String value;

  const StatsWidget(this.title, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          // Expanded hace que el texto del título ocupe todo el espacio sobrante.
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          // El texto del valor se alineará a la derecha.
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
