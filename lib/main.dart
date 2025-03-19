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
  late CameraController _cameraController;
  bool _isCameraInitialized = false;

  // Listas de marcos
  final List<String> verticalFrames = [
    'assets/marco-nacional-v.png',
    'assets/marco-santafe-v.png',
    'assets/marco-millos-v.png',
    'assets/marco-colombia-v.png',
    'assets/marco-cumple-v.png',
    'assets/marco-birthday-v.png',
    'assets/marco-party-v.png',
    'assets/marco-karaoke-v.png',
    'assets/marco-patricks-v.png',
    'assets/marco-christmas-v.png',
    'assets/marco-valentines-v.png',
    'assets/marco-halloween-v.png',
    
  ];
  final List<String> horizontalFrames = [
    'assets/marco-nacional-h.png',
    'assets/marco-santafe-h.png',
    'assets/marco-millos-h.png',
    'assets/marco-colombia-h.png',
    'assets/marco-cumple-h.png',
    'assets/marco-birthday-h.png',
    'assets/marco-party-h.png',
    'assets/marco-karaoke-h.png',
    'assets/marco-patricks-h.png',
    'assets/marco-christmas-h.png',
    'assets/marco-valentines-h.png',
    'assets/marco-halloween-h.png',
  ];

  int currentFrameIndex = 0;

  @override
  void initState() {
    super.initState();
    cameraHandler = MobileCamera();
    _cameraController = CameraController(
      widget.camera,
      ResolutionPreset.high,
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

  void changeFrame(int newIndex) {
    setState(() {
      currentFrameIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final frameAsset = (orientation == Orientation.portrait)
        ? verticalFrames[currentFrameIndex]
        : horizontalFrames[currentFrameIndex];

    return Scaffold(
      body: _isCameraInitialized
          ? Stack(
              alignment: Alignment.center,
              children: [
                // Vista previa de la cámara
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
                // Botones del carrusel y de captura
                Positioned(
                  bottom: 50,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botón para retroceder en el carrusel
                      IconButton(
                        iconSize: 40,
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          final maxIndex = (orientation == Orientation.portrait)
                              ? verticalFrames.length
                              : horizontalFrames.length;
                          changeFrame(
                              (currentFrameIndex - 1 + maxIndex) % maxIndex);
                        },
                      ),
                      // Botón para tomar la foto
                      FloatingActionButton(
                        onPressed: () async {
                          await cameraHandler.takePicture(
                              context, _cameraController, frameAsset);
                        },
                        child: Icon(Icons.camera, color: Colors.black),
                        backgroundColor: Colors.white,
                      ),
                      // Botón para avanzar en el carrusel
                      IconButton(
                        iconSize: 40,
                        icon: Icon(Icons.arrow_forward, color: Colors.white),
                        onPressed: () {
                          final maxIndex = (orientation == Orientation.portrait)
                              ? verticalFrames.length
                              : horizontalFrames.length;
                          changeFrame((currentFrameIndex + 1) % maxIndex);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }
}
