import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class WebCamera {
  late html.VideoElement _videoElement;
  late html.CanvasElement _canvasElement;
  bool _isCameraInitialized = false;
  double screenWidth = 920;  // Valor inicial, lo actualizaremos dinámicamente
  double screenHeight = 520; // Valor inicial, lo actualizaremos dinámicamente

  Future<void> initialize() async {
    print("Inicializando la cámara...");
    _getWindowSize();

    // Inicializar la cámara utilizando la API de la cámara web
    _videoElement = html.VideoElement();
    _videoElement.autoplay = true;

    // Ajustamos el video de la cámara para que cubra toda la pantalla
    _videoElement.style.objectFit = 'cover';

    try {
      print("Intentando acceder a la cámara...");
      // Obtener acceso a la cámara
      final stream = await html.window.navigator.mediaDevices!.getUserMedia({
        'video': true,
      });
      _videoElement.srcObject = stream;
      print("Cámara inicializada correctamente.");

      // Registrar la vista del elemento HTML en Flutter usando ui.platformViewRegistry
      ui.platformViewRegistry.registerViewFactory(
        'camera-view',
        (int viewId) => _videoElement,
      );

      // Crear un canvas para dibujar la cámara y el marco con el tamaño de la ventana
      _canvasElement = html.CanvasElement(width: screenWidth.toInt(), height: screenHeight.toInt());

      _isCameraInitialized = true;
    } catch (e) {
      print("Error al inicializar la cámara: $e");
    }
  }

  // Obtener las dimensiones de la ventana del navegador
  void _getWindowSize() {
    screenWidth = html.window.innerWidth!.toDouble();
    screenHeight = html.window.innerHeight!.toDouble();
    print("Dimensiones de la ventana obtenidas: $screenWidth x $screenHeight");
  }

  // Método para capturar el contenido del canvas
  Future<void> captureScreenshot() async {
    // Dibujar el video en el canvas, ajustado a las dimensiones del canvas
    final videoAspectRatio = screenWidth / screenHeight;
    final videoWidth = screenWidth;
    final videoHeight = screenWidth / videoAspectRatio;

    final offsetXVideo = 0;
    final offsetYVideo = (screenHeight - videoHeight) / 2;

    _canvasElement.context2D.drawImageScaled(_videoElement, offsetXVideo, offsetYVideo, videoWidth, videoHeight);

    // Cargar el marco y mantener la proporción
    final frameImage = html.ImageElement(src: 'assets/happy-birthday.png');
    await frameImage.onLoad.first;

    // Obtener las dimensiones del marco
    final frameWidth = frameImage.width!.toDouble();
    final frameHeight = frameImage.height!.toDouble();

    // Calcular el factor de escala dinámico basado en la relación entre el marco y la cámara
    final scaleWidth = screenWidth / frameWidth;
    final scaleHeight = screenHeight / frameHeight;
    final scale = scaleWidth < scaleHeight ? scaleWidth : scaleHeight;

    // Ajustamos las dimensiones escaladas del marco
    final scaledWidth = frameWidth * scale;
    final scaledHeight = frameHeight * scale;

    // Calcular las posiciones de centrado del marco
    final offsetXFrame = (screenWidth - scaledWidth) / 2;
    final offsetYFrame = (screenHeight - scaledHeight) / 2;

    // Dibujar el marco escalado y centrado en el canvas
    _canvasElement.context2D.drawImageScaled(frameImage, offsetXFrame, offsetYFrame, scaledWidth, scaledHeight);

    // Convertir el canvas a un blob
    final pngBlob = await _canvasElement.toBlob('image/png');

    // Crear un enlace de descarga para el usuario
    final url = html.Url.createObjectUrlFromBlob(pngBlob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "captura_con_marco.png")
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  Widget buildWebCameraWithFrame() {
    return _isCameraInitialized
        ? Stack(
            alignment: Alignment.center,
            children: [
              // Mostrar la cámara usando HtmlElementView ajustada al tamaño de la ventana
              Positioned.fill(
                child: HtmlElementView(viewType: 'camera-view'),
              ),
              // Superposición del marco ajustado al tamaño de la ventana
              Positioned.fill(
                child: Image.asset(
                  'assets/happy-birthday.png',  // Ruta de la imagen del marco
                  fit: BoxFit.contain,  // Ajustar el marco para mantener la proporción
                ),
              ),
            ],
          )
        : Center(child: CircularProgressIndicator()); // Mostrar mientras la cámara se inicializa
  }
}
