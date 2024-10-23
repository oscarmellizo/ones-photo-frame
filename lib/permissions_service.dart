import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  // Verifica si estás en Android
  if (Platform.isAndroid) {
    // En Android 10 o inferiores, solicitar los permisos de almacenamiento.
    if (await Permission.storage.request().isGranted) {
      print("================= Permiso de almacenamiento concedido");
    } else {
      print("################# Permiso de almacenamiento denegado temporalmente o permanentemente.");
      if (await Permission.storage.isPermanentlyDenied) {
        // Abre la configuración para que el usuario habilite los permisos
        print("################# Permiso de almacenamiento denegado permanentemente, abre configuración.");
        openAppSettings();
      }
    }

    // Si estás en Android 11 o superior, y necesitas gestionar todo el almacenamiento.
    if (Platform.isAndroid && Platform.operatingSystemVersion.contains("11") ||
        Platform.operatingSystemVersion.contains("12")) {
      // Solo usa MANAGE_EXTERNAL_STORAGE si es absolutamente necesario
      if (await Permission.manageExternalStorage.request().isGranted) {
        print("================= Permiso de gestión de almacenamiento concedido");
      } else {
        print("################# Permiso de gestión de almacenamiento denegado");
        if (await Permission.manageExternalStorage.isPermanentlyDenied) {
          print("################# Permiso de gestión de almacenamiento denegado permanentemente.");
          openAppSettings(); // Abre la configuración para que el usuario habilite manualmente
        }
      }
    }
  } else if (Platform.isIOS) {
    // Manejar permisos de almacenamiento en iOS (si es necesario)
    print("Estás en iOS, los permisos de almacenamiento son manejados de forma diferente.");
  }
}
