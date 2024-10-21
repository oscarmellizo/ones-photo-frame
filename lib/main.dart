import 'package:flutter/material.dart';
import 'camera_web.dart';  // Importamos el archivo de la cámara web

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraWithFrame(),
    );
  }
}

class CameraWithFrame extends StatefulWidget {
  @override
  _CameraWithFrameState createState() => _CameraWithFrameState();
}

class _CameraWithFrameState extends State<CameraWithFrame> {
  late WebCamera webCamera;

  @override
  void initState() {
    super.initState();
    webCamera = WebCamera();
    webCamera.initialize().then((_) {
      // Asegurarnos de que se reconstruya el widget cuando la cámara esté inicializada
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cámara con Marco')),
      body: Center(
        child: webCamera.buildWebCameraWithFrame(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: webCamera.captureScreenshot,
        child: Icon(Icons.camera),
      ),
    );
  }
}
