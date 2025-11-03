import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeSplitScreen extends StatefulWidget {
  const NativeSplitScreen({super.key});

  @override
  State<NativeSplitScreen> createState() => _NativeSplitScreenState();
}

class _NativeSplitScreenState extends State<NativeSplitScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const viewType = 'native-left-view';

    return Row(
      children: [
        // Occupy ~70% of the screen for the native Android view
        Expanded(
          flex: 7,
          child: AndroidView(
            viewType: viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: {'text': 'Hello from Flutter!'},
            creationParamsCodec: const StandardMessageCodec(),
          ),
        ),

        // Right side - Flutter UI
        Expanded(
          flex: 3,
          child: Container(
            color: Colors.blue,
            child: const Center(
              child: Text(
                'Flutter Side',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
