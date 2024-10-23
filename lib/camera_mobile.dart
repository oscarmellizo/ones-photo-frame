// camera_mobile.dart
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart'; // Para guardar la imagen
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart'
    as img; // Importa el paquete de manipulación de imágenes
import 'package:flutter/services.dart'
    show MethodChannel, PlatformException, rootBundle;

class MobileCamera {
  late CameraController _controller;
  bool _isCameraInitialized = false;

  Future<void> initialize(CameraController controller) async {
  try {
    await controller.initialize();
    _isCameraInitialized = true;
  } catch (e) {
    print("Error al inicializar la cámara: $e");
  }
}


  Future<void> saveImageToGallery(Uint8List imageData, String fileName) async {
    const platform = MethodChannel('com.example.ones_photo_frame/gallery');

    try {
      await platform.invokeMethod('saveImageToGallery', {
        'imageData': imageData,
        'fileName': fileName,
      });
    } on PlatformException catch (e) {
      print('Error al guardar la imagen: $e');
    }
  }

  /*Widget buildCameraWithFrame(BuildContext context, CameraController controller) {
    // Comprobar si el controlador de la cámara está inicializado
    if (!controller.value.isInitialized) {
      return Center(child: CircularProgressIndicator());  // Mostrar un indicador de carga
    }

    return Stack(
      children: [
        CameraPreview(_controller), // Muestra la vista previa de la cámara
        Positioned.fill(
          child: Image.asset(
            'assets/happy-birthday.png',
            fit: BoxFit.cover, // Ajuste del tamaño del marco
          ),
        ),
      ],
    );
  }*/

  Future<void> takePicture(
      BuildContext context, CameraController _controller, String frameAsset) async {
    if (!_controller.value.isInitialized) return;

    try {
      // Verificar permisos para la cámara
      var cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        print('Permiso de cámara denegado');
        return;
      }

      // Capturar la imagen desde la cámara
      final image = await _controller.takePicture();

      // Decodificar la imagen de la cámara
      final img.Image cameraImage =
          img.decodeImage(File(image.path).readAsBytesSync())!;

      // Cargar la imagen del marco desde los assets
      final ByteData frameData =
          await rootBundle.load(frameAsset);
      final Uint8List frameBytes = frameData.buffer.asUint8List();
      final img.Image frameImage = img.decodeImage(frameBytes)!;

      // Escalar el marco al mismo tamaño que la imagen de la cámara
      final img.Image resizedFrame = img.copyResize(frameImage,
          width: cameraImage.width, height: cameraImage.height);

      // Superponer el marco sobre la imagen de la cámara
      final img.Image finalImage =
          img.copyInto(cameraImage, resizedFrame, blend: true);

      // Guardar la imagen en un archivo temporal
      final Directory tempDir = await getTemporaryDirectory();
      final String final_file_name =
          '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String tempPath =
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File finalImageFile = File(tempPath)
        ..writeAsBytesSync(img.encodeJpg(finalImage));

      // Guardar la imagen en la galería (carpeta "Ones" en Pictures)
      final Uint8List finalImageBytes =
          Uint8List.fromList(img.encodeJpg(finalImage));
      await saveImageToGallery(finalImageBytes, final_file_name);

      // Mostrar confirmación
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Foto capturada'),
            content:
                Text('La imagen se ha guardado correctamente en la galería'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error al tomar la foto: $e');
    }
  }
}
