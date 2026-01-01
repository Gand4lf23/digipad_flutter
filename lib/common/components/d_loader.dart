import 'package:flutter/material.dart' show CircularProgressIndicator, Colors;
import 'package:flutter/widgets.dart';

class DLoader extends StatelessWidget {
  const DLoader({super.key, this.color, this.size});

  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: color ?? Colors.white,
        ),
      ),
    );
  }
}
