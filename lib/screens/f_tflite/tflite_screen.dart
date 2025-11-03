// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:flutter_tflite/flutter_tflite.dart';
// import 'dart:math' as math;

// // Asegúrate de que estos archivos y sus contenidos existan en tu proyecto
// import 'camera.dart';
// import 'bndbox.dart';
// import 'models.dart';

// class TfliteScreen extends StatefulWidget {
//   // El constructor ya no recibe ningún parámetro.
//   const TfliteScreen({super.key});

//   @override
//   TfliteScreenState createState() => TfliteScreenState();
// }

// class TfliteScreenState extends State<TfliteScreen> {
//   // Usaremos un Future para manejar la carga asíncrona de las cámaras.
//   late Future<List<CameraDescription>> _cameraFuture;

//   List<dynamic>? _recognitions;
//   int _imageHeight = 0;
//   int _imageWidth = 0;
//   String _model = "";

//   @override
//   void initState() {
//     super.initState();
//     // Iniciamos la obtención de las cámaras una sola vez.
//     _cameraFuture = availableCameras();
//   }

//   @override
//   void dispose() {
//     // Es una buena práctica cerrar Tflite cuando el widget se destruye.
//     Tflite.close();
//     super.dispose();
//   }

//   Future<void> loadModel() async {
//     String? res;
//     // Simplificamos la carga, ya que todos los casos eran idénticos.
//     // Si tienes modelos diferentes, puedes volver a usar el switch.
//     switch (_model) {
//       case yolo:
//       case mobilenet:
//       case ssd:
//         res = await Tflite.loadModel(
//           model: "assets/models/model.tflite",
//           labels: "assets/models/labels.txt",
//         );
//         break;
//       case posenet:
//         res = await Tflite.loadModel(model: "assets/models/model.tflite");
//         break;
//       default:
//         res = "Modelo no reconocido";
//     }
//     print("Resultado de la carga del modelo: $res");
//   }

//   void onSelect(model) {
//     setState(() {
//       _model = model;
//     });
//     loadModel();
//   }

//   void setRecognitions(recognitions, imageHeight, imageWidth) {
//     // Asegurarse de que el widget todavía está montado antes de llamar a setState.
//     if (mounted) {
//       setState(() {
//         _recognitions = recognitions;
//         _imageHeight = imageHeight;
//         _imageWidth = imageWidth;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     Size screen = MediaQuery.of(context).size;

//     // Si aún no se ha seleccionado un modelo, mostramos la pantalla de selección.
//     if (_model == "") {
//       return Scaffold(
//         appBar: AppBar(title: const Text("Seleccionar Modelo")),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               ElevatedButton(
//                 child: const Text(ssd),
//                 onPressed: () => onSelect(ssd),
//               ),
//               ElevatedButton(
//                 child: const Text(yolo),
//                 onPressed: () => onSelect(yolo),
//               ),
//               ElevatedButton(
//                 child: const Text(mobilenet),
//                 onPressed: () => onSelect(mobilenet),
//               ),
//               ElevatedButton(
//                 child: const Text(posenet),
//                 onPressed: () => onSelect(posenet),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     // Si ya se seleccionó un modelo, usamos FutureBuilder para esperar a las cámaras.
//     return Scaffold(
//       body: FutureBuilder<List<CameraDescription>>(
//         future: _cameraFuture,
//         builder: (context, snapshot) {
//           // Mientras espera, muestra un indicador de carga.
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           // Si hubo un error (ej. permisos denegados).
//           if (snapshot.hasError) {
//             return Center(
//               child: Text('Error al acceder a las cámaras: ${snapshot.error}'),
//             );
//           }
//           // Si no se encontraron cámaras.
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No se encontraron cámaras.'));
//           }

//           // Si todo está bien, construye la vista de la cámara.
//           final cameras = snapshot.data!;
//           return Stack(
//             children: [
//               Camera(cameras, _model, setRecognitions),
//               BndBox(
//                 _recognitions ??
//                     [], // Forma más segura de manejar el valor nulo.
//                 math.max(_imageHeight, _imageWidth),
//                 math.min(_imageHeight, _imageWidth),
//                 screen.height,
//                 screen.width,
//                 _model,
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
