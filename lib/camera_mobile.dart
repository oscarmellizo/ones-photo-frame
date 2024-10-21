import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';

class MobileCamera {
  late CameraController _cameraController;
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  // Inicialización de la cámara para Android/iOS
  Future<void> initialize(List<CameraDescription> cameras) async {
    _cameraController = CameraController(
      cameras[0],  // Usamos la cámara trasera
      ResolutionPreset.high,
    );
    await _cameraController.initialize();
  }

  // Construcción de la cámara con el marco para móviles
  Widget buildMobileCameraWithFrame() {
    return RepaintBoundary(
      key: _repaintBoundaryKey,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _cameraController.value.aspectRatio,
            child: CameraPreview(_cameraController),
          ),
          Positioned.fill(
            child: Image.asset(
              'assets/happy-birthday.png',  // Ruta de la imagen del marco
              fit: BoxFit.contain,  // Ajustar el marco para mantener la proporción
            ),
          ),
        ],
      ),
    );
  }

  // Captura de imagen para Android/iOS
  Future<void> captureScreenshot() async {
    try {
      RenderRepaintBoundary boundary =
          _repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage();
      var byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/captura_con_marco.png';
      File(imagePath).writeAsBytes(pngBytes);

      print("Imagen guardada en: $imagePath");
    } catch (e) {
      print("Error al capturar la imagen: $e");
    }
  }
}
