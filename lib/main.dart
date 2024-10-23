import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_mobile.dart';
import 'permissions_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Solicitar permisos antes de inicializar la cámara
  await requestPermissions();

  // Obtener la lista de cámaras disponibles
  List<CameraDescription> cameras = [];
  try {
    cameras = await availableCameras();
  } catch (e) {
    print('Error al obtener las cámaras disponibles: $e');
  }

  if (cameras.isEmpty) {
    print('No hay cámaras disponibles');
    return;
  }

  runApp(MyApp(camera: cameras.first));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  MyApp({required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraWithFrame(camera: camera),
    );
  }
}

class CameraWithFrame extends StatefulWidget {
  final CameraDescription camera;

  CameraWithFrame({required this.camera});

  @override
  _CameraWithFrameState createState() => _CameraWithFrameState();
}

class _CameraWithFrameState extends State<CameraWithFrame> {
  late MobileCamera cameraHandler;
  late CameraController _cameraController; // Crear el CameraController
  bool _isCameraInitialized =
      false; // Para indicar si la cámara está inicializada

  @override
  void initState() {
    super.initState();
    cameraHandler = MobileCamera();
    _cameraController = CameraController(
      widget.camera, // Utilizamos la cámara pasada al widget
      ResolutionPreset.high, // Definimos una resolución para la cámara
    );
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraController.initialize();
      print('Cámara inicializada correctamente');
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print('Error al inicializar la cámara: $e');
      setState(() {
        _isCameraInitialized = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
// Detectar la orientación del dispositivo
    final orientation = MediaQuery.of(context).orientation;
    // Seleccionar la imagen del marco según la orientación
    final frameAsset = orientation == Orientation.portrait
        ? 'assets/marco-vertical.png' // Marco para modo vertical
        : 'assets/marco-horizontal.png'; // Marco para modo horizontal

    return Scaffold(
      body: _isCameraInitialized
          ? LayoutBuilder(
              // Usamos LayoutBuilder para conocer el tamaño exacto disponible
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // La vista previa de la cámara, ajustada al tamaño de la pantalla
                    Positioned.fill(
                      child: AspectRatio(
                        aspectRatio: _cameraController.value.aspectRatio,
                        child: CameraPreview(
                            _cameraController), // Vista previa de la cámara
                      ),
                    ),
                    // El marco se ajusta completamente a la pantalla
                    Positioned.fill(
                      child: Image.asset(
                        frameAsset, // Ruta del marco
                        fit: BoxFit
                            .fill, // Asegura que el marco cubra toda la pantalla
                      ),
                    ),
                  ],
                );
              },
            )
          : Center(
              child:
                  CircularProgressIndicator()), // Mostrar el indicador mientras se inicializa la cámara
      floatingActionButton: _isCameraInitialized
          ? FloatingActionButton(
              onPressed: () async {
                await cameraHandler.takePicture(context, _cameraController, frameAsset);
              },
              child: Icon(Icons.camera),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _cameraController
        .dispose(); // Limpiar el controlador cuando se termine de usar
    super.dispose();
  }
}
