import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await _isAndroid13OrHigher()) {
        var statusImages = await Permission.photos.status;
        if (!statusImages.isGranted) {
          statusImages = await Permission.photos.request();
        }
        return statusImages.isGranted;
      } else {
        var statusStorage = await Permission.storage.status;
        if (!statusStorage.isGranted) {
          statusStorage = await Permission.storage.request();
        }
        return statusStorage.isGranted;
      }
    }

    // You can add iOS or desktop logic here if needed
    return true;
  }

  static Future<bool> _isAndroid13OrHigher() async {
    final version = int.parse(Platform.operatingSystemVersion
        .split(' ')
        .firstWhere((e) => RegExp(r'^\d{2,}').hasMatch(e))
        .replaceAll(RegExp(r'[^0-9]'), ''));

    return version >= 33;
  }
}
