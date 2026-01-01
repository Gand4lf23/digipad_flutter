import 'package:digipad_flutter/screens/home_screen.dart';
import 'package:flutter/material.dart';

/// [HomeView] stacks [DetectorWidget]
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: GlobalKey(),
      backgroundColor: Colors.black,

      body: const HomeScreen(),
    );
  }
}
